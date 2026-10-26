import Testing

@testable import NeNePokerCore

/// ブラインド・手番・最小のベットとレイズ・足りないオールイン（FR-02・ADR 0007・Robert's Rules of Poker Version 11）。
@Suite struct BettingTests {
    @Test func fourHandedBlindsSitLeftOfTheButtonAndTheSeatAfterTheBigBlindActsFirst() throws {
        let table = TableFixture.table([1_000, 1_000, 1_000, 1_000], button: .south)
        let hand = table.dealHand(order: try TableFixture.order(for: table, holes: [:]))
        #expect(hand.smallBlindSeat == .west)
        #expect(hand.bigBlindSeat == .north)
        #expect(hand.progress == .awaitingAction(.east))
        #expect(hand.streetBet(of: .west) == 10)
        #expect(hand.streetBet(of: .north) == 20)
        #expect(hand.pot == 30)
    }

    @Test func headsUpTheButtonPostsTheSmallBlindActsFirstPreflopAndLastAfterTheFlop() throws {
        let table = TableFixture.table([1_000, 0, 1_000, 0], button: .north)
        let hand = table.dealHand(order: try TableFixture.order(for: table, holes: [:]))
        #expect(hand.smallBlindSeat == .north)
        #expect(hand.bigBlindSeat == .south)
        #expect(hand.progress == .awaitingAction(.north))
        let flop = TableFixture.dealing(try TableFixture.play([.call, .check], from: hand))
        #expect(flop.street == .flop)
        #expect(flop.progress == .awaitingAction(.south))
    }

    @Test func theBigBlindGetsTheOptionWhenEveryoneLimps() throws {
        let table = TableFixture.table([1_000, 1_000, 1_000, 1_000])
        let hand = try TableFixture.play(
            [.call, .call, .call], from: table.dealHand(order: TableFixture.order(for: table, holes: [:])))
        #expect(hand.progress == .awaitingAction(.north))
        let legal = try #require(hand.legalActions)
        #expect(legal.check)
        #expect(legal.raise == 40...999)
        #expect(!legal.fold)
    }

    @Test func aRaiseMustBeAtLeastThePreviousBetOrRaise() throws {
        let table = TableFixture.table([1_000, 1_000, 1_000, 1_000])
        let start = table.dealHand(order: try TableFixture.order(for: table, holes: [:]))
        #expect(start.legalActions?.raise?.lowerBound == 40)
        let raised = try TableFixture.play([.raise(70)], from: start)
        #expect(raised.legalActions?.raise?.lowerBound == 120)
        #expect(raised.apply(.raise(119)) == .rejected(.amountBelowMinimum))
        #expect(raised.apply(.bet(200)) == .rejected(.betNotOpen))
        #expect(raised.apply(.check) == .rejected(.checkFacingBet))
    }

    @Test func theMinimumBetAfterTheFlopIsTheBigBlindAndAllChipsAreAnAllIn() throws {
        let table = TableFixture.table([1_000, 0, 1_000, 0], button: .north)
        let flop = TableFixture.dealing(
            try TableFixture.play(
                [.call, .check], from: table.dealHand(order: TableFixture.order(for: table, holes: [:]))))
        let legal = try #require(flop.legalActions)
        #expect(legal.bet == 20...979)
        #expect(legal.allIn == 980)
        #expect(flop.apply(.bet(19)) == .rejected(.amountBelowMinimum))
        #expect(flop.apply(.bet(980)) == .rejected(.amountIsAllIn))
        #expect(flop.apply(.fold) == .rejected(.foldWithoutBet))
        #expect(flop.apply(.call) == .rejected(.callNotPossible))
    }

    /// Robert's Rules の第 14 節の 3 の例: A が 100 を賭け、B が 200 に上げ、C が 250 のオールイン（満額のレイズに届かない）。
    /// A はレイズできる（B が満額で上げたから）。A がコールしたあと、B はレイズできない（満額のレイズに向き合っていない）。
    @Test func anAllInBelowAFullRaiseDoesNotReopenTheBettingForThePlayerWhoRaised() throws {
        let table = TableFixture.table([1_000, 1_000, 270, 0], button: .north)
        let hand = TableFixture.dealing(
            try TableFixture.play(
                [.call, .call, .check], from: table.dealHand(order: TableFixture.order(for: table, holes: [:]))))
        #expect(hand.progress == .awaitingAction(.south))
        let shoved = try TableFixture.play([.bet(100), .raise(200), .allIn], from: hand)
        #expect(shoved.highestBet == 250)
        #expect(shoved.legalActions?.raise?.lowerBound == 350)
        let called = try TableFixture.play([.call], from: shoved)
        #expect(called.progress == .awaitingAction(.west))
        let legal = try #require(called.legalActions)
        #expect(legal.raise == nil)
        #expect(legal.allIn == nil)
        #expect(legal.call == 50)
        #expect(called.apply(.raise(400)) == .rejected(.raiseNotOpen))
        #expect(called.apply(.allIn) == .rejected(.allInWouldReopen))
    }

    /// Robert's Rules の第 14 節の 4: 足りないオールインが重なって満額のレイズに届けば、レイズの権利が開く。
    @Test func twoShortAllInsThatTogetherMakeAFullRaiseReopenTheBetting() throws {
        let table = TableFixture.table([1_000, 1_000, 270, 320], button: .east)
        var hand = table.dealHand(order: try TableFixture.order(for: table, holes: [:]))
        hand = TableFixture.dealing(try TableFixture.play([.call, .call, .call, .check], from: hand))
        #expect(hand.progress == .awaitingAction(.south))
        hand = try TableFixture.play([.bet(100), .raise(200), .allIn, .allIn], from: hand)
        #expect(hand.highestBet == 300)
        hand = try TableFixture.play([.call], from: hand)
        #expect(hand.progress == .awaitingAction(.west))
        #expect(hand.legalActions?.raise?.lowerBound == 400)
    }

    @Test func aShortStackPostsWhatItHasForTheBlindAndIsAllIn() throws {
        let table = TableFixture.table([1_000, 6, 1_000, 0], button: .south)
        let hand = table.dealHand(order: try TableFixture.order(for: table, holes: [:]))
        #expect(hand.streetBet(of: .west) == 6)
        #expect(hand.status(of: .west) == .allIn)
        #expect(hand.progress == .awaitingAction(.south))
        #expect(hand.legalActions?.call == 20)
    }

    @Test func noActionIsTakenWhileTheBoardIsWaitingToBeDealt() throws {
        let table = TableFixture.table([1_000, 0, 1_000, 0], button: .north)
        let hand = try TableFixture.play(
            [.call, .check], from: table.dealHand(order: TableFixture.order(for: table, holes: [:])))
        #expect(hand.progress == .awaitingDeal(.flop))
        #expect(hand.apply(.check) == .rejected(.noActionPending))
        #expect(hand.dealNextStreet().board.count == 3)
    }
}
