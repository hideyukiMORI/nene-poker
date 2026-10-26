/// 4 人の卓（FR-01・FR-04・ADR 0007）。チップが 0 になった席は抜け、最後の 1 人が全チップを取ったら優勝。
///
/// 親は時計回りに次のチップのある席へ動く（Robert's Rules of Poker・Version 11 の第 4 節の 2(a) Moving button）。
/// 残りが 2 人になったら、親がスモールブラインドを出す。2 人になったとき、いちばん最近ビッグブラインドを出した人が親になる（同じ節の 3）。
public struct Table: Sendable, Hashable {
    /// 卓の決まり。
    public let rules: TableRules
    /// 次のハンドの親。
    public let button: Seat
    /// 次のハンドの 1 から始まる番号。
    public let handNumber: Int

    let stacks: [Int]
    let lastBigBlind: [Int]

    private init(rules: TableRules, button: Seat, handNumber: Int, stacks: [Int], lastBigBlind: [Int]) {
        self.rules = rules
        self.button = button
        self.handNumber = handNumber
        self.stacks = stacks
        self.lastBigBlind = lastBigBlind
    }

    /// 全員が初期のチップを持ち、button を親にして卓を始める。
    public static func starting(rules: TableRules, button: Seat) -> Table {
        Table(
            rules: rules, button: button, handNumber: 1, stacks: Array(repeating: rules.startingStack, count: 4),
            lastBigBlind: Array(repeating: 0, count: 4))
    }

    /// 途中の卓（各席のチップと親とハンド番号を決めて作る）。手作りの局面を作るテストのための internal の経路。
    static func arranged(rules: TableRules, button: Seat, stacks: [Int], handNumber: Int) -> Table {
        precondition(stacks.count == 4 && stacks.allSatisfy { $0 >= 0 } && handNumber >= 1, "4 席のチップは 0 以上")
        return Table(
            rules: rules, button: button, handNumber: handNumber, stacks: stacks,
            lastBigBlind: Array(repeating: 0, count: 4))
    }

    /// 席のチップ。
    public func stack(of seat: Seat) -> Int {
        stacks[seat.rawValue]
    }

    /// チップのある席（時計回りの順）。
    public var liveSeats: [Seat] {
        Seat.allCases.filter { stacks[$0.rawValue] > 0 }
    }

    /// 1 人だけがチップを持っていれば、その優勝者。
    public var champion: Seat? {
        let live = liveSeats
        return live.count == 1 ? live.first : nil
    }

    /// 全員のチップの合計（卓の中で変わらない）。
    public var totalChips: Int {
        stacks.reduce(0, +)
    }

    /// 次のハンドのブラインドの段階。
    public var blindLevel: BlindLevel {
        rules.schedule.level(forHand: handNumber)
    }

    /// 次のハンドを、渡された 52 枚の配る順で始める（優勝者が決まっていないときだけ）。
    public func dealHand(order: [Card]) -> Hand {
        precondition(champion == nil && liveSeats.count >= 2, "ハンドは 2 人以上がチップを持つときだけ配る")
        let live = liveSeats
        let next = { (seat: Seat) in seat.clockwiseFromNext.first { live.contains($0) } ?? seat }
        let smallBlind = live.count == 2 ? button : next(button)
        let seating = Seating(
            button: button, smallBlind: smallBlind, bigBlind: next(smallBlind), level: blindLevel, number: handNumber)
        return Hand.dealing(seating, stacks: stacks, order: order)
    }

    /// 終わったハンドの結果を反映した、次のハンドの前の卓。
    public func after(_ hand: Hand) -> Table {
        guard case .complete(let result) = hand.progress else {
            preconditionFailure("終わったハンドだけを反映する")
        }
        let stacks = Seat.allCases.map { result.stacks[$0, default: 0] }
        var lastBigBlind = lastBigBlind
        lastBigBlind[hand.bigBlindSeat.rawValue] = hand.number
        let played = Seat.allCases.filter { hand.status(of: $0) != .out }.count
        let live = Seat.allCases.filter { stacks[$0.rawValue] > 0 }
        let button = Table.nextButton(
            after: hand.button, live: live, headsUpStarts: played > 2, lastBigBlind: lastBigBlind)
        return Table(
            rules: rules, button: button, handNumber: handNumber + 1, stacks: stacks, lastBigBlind: lastBigBlind)
    }

    /// 次の親。2 人になったところなら、いちばん最近ビッグブラインドを出した人。それ以外は時計回りに次のチップのある席。
    private static func nextButton(after button: Seat, live: [Seat], headsUpStarts: Bool, lastBigBlind: [Int]) -> Seat {
        let clockwise = button.clockwiseFromNext.first { live.contains($0) } ?? button
        guard live.count == 2, headsUpStarts else {
            return clockwise
        }
        let recent = live.max { lastBigBlind[$0.rawValue] < lastBigBlind[$1.rawValue] } ?? clockwise
        return lastBigBlind[recent.rawValue] > 0 ? recent : clockwise
    }
}
