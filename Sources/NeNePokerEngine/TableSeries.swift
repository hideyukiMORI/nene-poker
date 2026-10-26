import NeNePokerCore

/// 卓の列: いまの卓とハンド・席のキャスト・何卓目か・通算の優勝・このハンドの出来事・発言（ARC-004・ADR 0008・0012）。
///
/// 値型で、1 歩進めると新しい値を返す。時計を知らない（「何秒に 1 歩進めるか」は合成ルートが決める）。
/// 乱数は引数から受け取るので、同じシードの乱数源からは同じ卓の列と同じ発言が出る（FR-05）。表示のモード（VIEW）は知らない（FR-07a）。
public struct TableSeries: Sendable, Hashable {
    /// いまのハンドを配る前の卓（卓が終わったあとは、終わったときの卓）。
    public let table: Table
    /// いまのハンド（終わったあとは最後のハンド）。
    public let hand: Hand
    /// 段階。
    public let phase: SeriesPhase
    /// 何卓目か（1 から）。
    public let tableNumber: Int
    /// この卓の席とキャスト（メインの子は南）。
    public let lineup: Lineup
    /// 終わった卓の通算の優勝。
    public let tally: ChampionTally
    /// いまのハンドの出来事（古い順）。
    public let events: [TableEvent]
    /// 発言（COMMS）。
    public let banter: Banter
    private let rules: TableRules

    private init(state: SeriesState, rules: TableRules) {
        table = state.table
        hand = state.hand
        phase = state.phase
        tableNumber = state.tableNumber
        lineup = state.lineup
        tally = state.tally
        events = state.events
        banter = state.banter
        self.rules = rules
    }

    /// 製品の決まりの第 1 卓から始まる列。席のキャスト（メインの子を含む）と最初の親は乱数で決める。
    public static func first(using generator: inout some RandomNumberGenerator) -> TableSeries {
        first(rules: TableSetup.standard, using: &generator)
    }

    /// 決まりを決めた列（テストで短い卓を回すため）。
    static func first(rules: TableRules, using generator: inout some RandomNumberGenerator) -> TableSeries {
        opening(SeriesRecord(tableNumber: 1, tally: .zero, banter: .silent), rules: rules, using: &generator)
    }

    /// 1 歩進める: 行動か場札を 1 つ、ハンドの終わりの次は次のハンド、卓の終わりの次は次の卓。
    public func advanced(using generator: inout some RandomNumberGenerator) -> TableSeries {
        switch phase {
        case .playing:
            return stepped(using: &generator)
        case .handOver:
            return afterHand(using: &generator)
        case .tableOver:
            let record = SeriesRecord(tableNumber: tableNumber + 1, tally: tally, banter: banter)
            return Self.opening(record, rules: rules, using: &generator)
        }
    }

    /// ハンドの終わりの次: 優勝が決まれば卓の終わり（優勝した人が必ず話す）、そうでなければ次のハンドを配る。
    private func afterHand(using generator: inout some RandomNumberGenerator) -> TableSeries {
        let next = table.after(hand)
        if let champion = next.champion {
            let said = banter.after(
                [Prompt(seat: champion, cue: .champion, chance: 100)], lineup: lineup, using: &generator)
            let record = tally.recording(lineup.persona(at: champion))
            return with(
                SeriesState(
                    table: next, hand: hand, phase: .tableOver(champion: champion), tableNumber: tableNumber,
                    lineup: lineup, tally: record, events: events, banter: said))
        }
        let dealt = next.dealHand(order: Deck.dealingOrder(using: &generator))
        return with(
            SeriesState(
                table: next, hand: dealt, phase: .playing, tableNumber: tableNumber, lineup: lineup, tally: tally,
                events: [], banter: banter.after([], lineup: lineup, using: &generator)))
    }

    /// ハンドの途中の 1 歩（手番の行動か、場札を開く）。
    private func stepped(using generator: inout some RandomNumberGenerator) -> TableSeries {
        switch hand.progress {
        case .awaitingAction(let seat):
            let action = ActionChooser.choose(in: hand, style: lineup.persona(at: seat).style, using: &generator)
            guard case .applied(let next) = hand.apply(action) else {
                preconditionFailure("合法な一覧から選んだ行動は必ず適用できる: \(action)")
            }
            let roll = Int.random(in: 0..<12, using: &generator)
            let prompts = BanterPrompts.after(action, by: seat, in: next, idleRoll: banter.isQuiet() ? roll : nil)
            return continuing(next, event: .acted(seat, action, total: next.streetBet(of: seat)), prompts, &generator)
        case .awaitingDeal(let street):
            let next = hand.dealNextStreet()
            let event = TableEvent.dealt(street, Array(next.board.dropFirst(hand.board.count)))
            return continuing(next, event: event, [], &generator)
        case .complete:
            return with(state(hand: hand, phase: .handOver, events: events, banter: banter))
        }
    }

    private func continuing(
        _ next: Hand, event: TableEvent, _ prompts: [Prompt], _ generator: inout some RandomNumberGenerator
    ) -> TableSeries {
        switch next.progress {
        case .awaitingAction, .awaitingDeal:
            let said = banter.after(prompts, lineup: lineup, using: &generator)
            return with(state(hand: next, phase: .playing, events: events + [event], banter: said))
        case .complete(let result):
            let said = banter.after(BanterPrompts.after(result, in: next) + prompts, lineup: lineup, using: &generator)
            return with(state(hand: next, phase: .handOver, events: events + [event], banter: said))
        }
    }

    private func state(hand: Hand, phase: SeriesPhase, events: [TableEvent], banter: Banter) -> SeriesState {
        SeriesState(
            table: table, hand: hand, phase: phase, tableNumber: tableNumber, lineup: lineup, tally: tally,
            events: events,
            banter: banter)
    }

    private func with(_ state: SeriesState) -> TableSeries {
        TableSeries(state: state, rules: rules)
    }

    /// 新しい卓: キャストを席に並べ直し、親を乱数で決め、最初のハンドを配る。メインの子と、もう 1 人がひと言ずつ。
    private static func opening(
        _ record: SeriesRecord, rules: TableRules, using generator: inout some RandomNumberGenerator
    ) -> TableSeries {
        let lineup = Lineup.drawn(from: Persona.cast, using: &generator)
        let button = Seat.allCases.randomElement(using: &generator) ?? .south
        let table = Table.starting(rules: rules, button: button)
        let hand = table.dealHand(order: Deck.dealingOrder(using: &generator))
        let other = Seat.allCases.dropFirst().randomElement(using: &generator) ?? .north
        let said = record.banter.saying(
            Prompt(seat: other, cue: .start, chance: 100), lineup: lineup, using: &generator
        )
        .saying(Prompt(seat: .south, cue: .start, chance: 100), lineup: lineup, using: &generator)
        return TableSeries(
            state: SeriesState(
                table: table, hand: hand, phase: .playing, tableNumber: record.tableNumber, lineup: lineup,
                tally: record.tally, events: [], banter: said),
            rules: rules)
    }
}
