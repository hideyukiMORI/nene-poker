import Testing

@testable import NeNePokerCore

/// 卓の進み方（親の回り方・ヘッズアップへの移り方・優勝）と、乱数で打った多数のハンドの不変条件（FR-01・FR-02・FR-04・ADR 0007）。
@Suite struct TableTests {
    @Test func theButtonMovesClockwiseToTheNextSeatWithChips() throws {
        let table = TableFixture.table([1_000, 1_000, 0, 1_000], button: .west)
        let hand = try TableFixture.play(
            [.fold, .fold], from: table.dealHand(order: TableFixture.order(for: table, holes: [:])))
        let next = table.after(TableFixture.dealing(hand))
        #expect(next.button == .east)
        #expect(next.handNumber == 2)
    }

    /// Robert's Rules の第 4 節の 3: 2 人になったとき、いちばん最近ビッグブラインドを出した人が親になる。
    /// 時計回りに動かすだけなら北が親になる場面で、直前のハンドでビッグブラインドを出した南が親になる。
    @Test func whenPlayBecomesHeadsUpThePlayerWhoLastPostedTheBigBlindGetsTheButton() throws {
        let first = TableFixture.table([1_000, 30, 1_000, 0], button: .south)
        let folded = try TableFixture.play(
            [.fold, .fold], from: first.dealHand(order: TableFixture.order(for: first, holes: [:])))
        let second = first.after(TableFixture.dealing(folded))
        #expect(second.button == .west)
        let order = try TableFixture.order(
            for: second, holes: [.west: "7c 2d", .south: "Ks Kd"], board: "3c 8h 9d Jc 4s")
        let hand = try TableFixture.play([.allIn, .fold], from: second.dealHand(order: order))
        #expect(hand.bigBlindSeat == .south)
        let headsUp = second.after(TableFixture.dealing(hand))
        #expect(headsUp.liveSeats == [.south, .north])
        #expect(headsUp.button == .south)
        let next = headsUp.dealHand(order: try TableFixture.order(for: headsUp, holes: [:]))
        #expect(next.smallBlindSeat == .south)
        #expect(next.bigBlindSeat == .north)
    }

    @Test func aTableWithOneSeatHoldingEveryChipHasAChampion() {
        let table = TableFixture.table([4_000, 0, 0, 0])
        #expect(table.champion == .south)
        #expect(TableFixture.table([3_000, 1_000, 0, 0]).champion == nil)
    }

    @Test func theBlindsRiseEveryLevelAndStayAtTheLastLevel() throws {
        let schedule = try #require(BlindSchedule.make(bigBlinds: [20, 40, 80], handsPerLevel: 3))
        #expect([1, 3, 4, 6, 7, 100].map { schedule.level(forHand: $0).bigBlind } == [20, 20, 40, 40, 80, 80])
        #expect(schedule.level(forHand: 4).smallBlind == 20)
        #expect(BlindSchedule.make(bigBlinds: [40, 20], handsPerLevel: 3) == nil)
        #expect(BlindSchedule.make(bigBlinds: [], handsPerLevel: 3) == nil)
    }

    /// 乱数で打った卓を最後まで流し、どの時点でも「チップ＋場のチップ」が変わらない・同じ札が 2 度出ない・どの卓も 1 人の優勝で終わる。
    @Test(arguments: 0..<200)
    func randomTablesConserveChipsDealEachCardOnceAndEndWithAChampion(_ seed: Int) {
        var generator = SplitMix64(seed: 0xC41B_0000 &+ UInt64(seed))
        let rules = TableFixture.rules
        var table = Table.starting(rules: rules, button: Seat.allCases[seed % 4])
        let total = table.totalChips
        while table.champion == nil, table.handNumber <= 5_000 {
            let hand = table.dealHand(order: Deck.dealingOrder(using: &generator))
            var actions: [Action] = []
            let finished = RandomActor.playOut(hand, using: &generator, actions: &actions) { current in
                let chips = Seat.allCases.reduce(0) { $0 + current.stack(of: $1) } + current.pot
                #expect(chips == total)
                let cards = Seat.allCases.flatMap(current.holeCards(of:)) + current.board
                #expect(Set(cards).count == cards.count)
            }
            table = table.after(finished)
            #expect(table.totalChips == total)
        }
        #expect(table.champion != nil)
    }

    @Test func theSameSeedPlaysTheSameActions() {
        #expect(TableTests.actionLog(seed: 7) == TableTests.actionLog(seed: 7))
        #expect(TableTests.actionLog(seed: 7) != TableTests.actionLog(seed: 8))
    }

    /// シードから 30 ハンドを乱数で打ち、行動の列を並べる。
    private static func actionLog(seed: UInt64) -> [Action] {
        var generator = SplitMix64(seed: seed)
        var table = Table.starting(rules: TableFixture.rules, button: .south)
        var actions: [Action] = []
        for _ in 0..<30 where table.champion == nil {
            let hand = table.dealHand(order: Deck.dealingOrder(using: &generator))
            table = table.after(RandomActor.playOut(hand, using: &generator, actions: &actions) { _ in })
        }
        return actions
    }
}
