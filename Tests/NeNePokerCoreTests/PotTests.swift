import Testing

@testable import NeNePokerCore

/// サイドポット・スプリットと端数・降りた人の分（FR-02・ADR 0007・Robert's Rules of Poker Version 11 の第 3 節 Ties）。
@Suite struct PotTests {
    @Test func everyoneFoldsToTheBigBlindWhoTakesTheBlindsWithoutShowing() throws {
        let table = TableFixture.table([1_000, 1_000, 1_000, 1_000])
        let hand = try TableFixture.play(
            [.fold, .fold, .fold], from: table.dealHand(order: TableFixture.order(for: table, holes: [:])))
        let result = try TableFixture.result(of: hand)
        #expect(result.ending == .uncontested)
        #expect(result.shown.isEmpty)
        #expect(result.stacks[.north] == 1_010)
        #expect(result.stacks[.west] == 990)
    }

    @Test func oneShortAllInMakesAMainPotAndASidePot() throws {
        let table = TableFixture.table([1_000, 1_000, 300, 0], button: .north)
        let order = try TableFixture.order(
            for: table, holes: [.north: "As Ad", .south: "Ks Kd", .west: "Qs Qd"], board: "2c 7h 9d Jc 3s")
        let hand = try TableFixture.play([.allIn, .call, .call, .bet(100), .call], from: table.dealHand(order: order))
        let ended = try TableFixture.play([.check, .check, .check, .check], from: hand)
        let result = try TableFixture.result(of: ended)
        #expect(result.ending == .showdown)
        #expect(result.awards.map(\.amount) == [900, 200])
        #expect(result.awards.map(\.winners) == [[.north], [.south]])
        #expect(result.awards[1].contenders == [.south, .west])
        #expect(result.stacks == [.south: 800, .west: 600, .north: 900, .east: 0])
    }

    @Test func threeAllInsMakeAMainPotAndTwoSidePots() throws {
        let table = TableFixture.table([100, 200, 300, 1_000], button: .east)
        let order = try TableFixture.order(
            for: table, holes: [.south: "As Ad", .west: "Ks Kd", .north: "Qs Qd", .east: "Js Jd"],
            board: "2c 7h 9d 4c 3s")
        let hand = try TableFixture.play([.allIn, .call, .allIn, .allIn], from: table.dealHand(order: order))
        let result = try TableFixture.result(of: hand)
        #expect(result.awards.map(\.amount) == [400, 300, 200])
        #expect(result.awards.map(\.winners) == [[.south], [.west], [.north]])
        #expect(result.stacks == [.south: 400, .west: 300, .north: 200, .east: 700])
    }

    @Test func aFoldedPlayersChipsStayInThePotButTheyCannotWinIt() {
        let stakes = PotTests.stakes([.south: 50, .west: 200, .north: 200], contenders: [.west, .north], allIn: [])
        let awards = PotDivision.divide(
            stakes, strengths: [.west: PotTests.strength(.pair), .north: PotTests.strength(.high)], button: .south)
        #expect(awards.map(\.amount) == [450])
        #expect(awards.map(\.winners) == [[.west]])
    }

    /// 賭けの途中で額がそろっていなくても、オールインが無ければポットは 1 つ（ブラインドだけでサイドポットを作らない）。
    @Test func unmatchedBetsWithoutAnAllInMakeOnePot() {
        let stakes = PotTests.stakes([.west: 10, .north: 20], contenders: Set(Seat.allCases), allIn: [])
        #expect(
            PotDivision.layers(stakes, button: .south) == [
                PotLayer(amount: 30, contenders: [.west, .north, .east, .south])
            ])
        let short = PotTests.stakes(
            [.west: 10, .north: 15, .east: 60], contenders: Set(Seat.allCases), allIn: [.north])
        #expect(PotDivision.layers(short, button: .south).map(\.amount) == [40, 45])
        #expect(PotDivision.layers(short, button: .south)[1].contenders == [.west, .east, .south])
    }

    /// Robert's Rules の Ties の 5(a): 割り切れないチップは、親から時計回りで最初の手が受け取る。
    @Test func aSplitGivesTheOddChipToTheFirstWinnerClockwiseFromTheButton() {
        let pair = PotTests.strength(.pair)
        let high = PotTests.strength(.high)
        let awards = PotDivision.divide(
            PotTests.stakes(
                [.south: 101, .west: 100, .north: 100], contenders: [.south, .west, .north], allIn: [.west, .north]),
            strengths: [.south: high, .west: pair, .north: pair], button: .west)
        #expect(awards.map(\.amount) == [300, 1])
        #expect(awards[0].winners == [.north, .west])
        #expect(awards[0].shares == [150, 150])
        #expect(awards[1].winners == [.south])
        let odd = PotDivision.divide(
            PotTests.stakes(
                [.west: 101, .north: 100, .east: 100], contenders: [.west, .north, .east], allIn: [.north, .east]),
            strengths: [.west: pair, .north: pair, .east: pair], button: .north)
        #expect(odd.map(\.amount) == [300, 1])
        #expect(odd[0].winners == [.east, .west, .north])
        #expect(odd[0].shares == [100, 100, 100])
        let two = PotDivision.divide(
            PotTests.stakes([.south: 51, .west: 50], contenders: [.south, .west], allIn: [.west]),
            strengths: [.south: pair, .west: pair], button: .west)
        #expect(two.map(\.amount) == [100, 1])
        let threeWay = PotDivision.divide(
            PotTests.stakes([.west: 67, .north: 67, .east: 67], contenders: [.west, .north, .east], allIn: []),
            strengths: [.west: pair, .north: pair, .east: high], button: .west)
        #expect(threeWay[0].winners == [.north, .west])
        #expect(threeWay[0].shares == [101, 100])
    }

    private static func stakes(_ contributions: [Seat: Int], contenders: Set<Seat>, allIn: Set<Seat>) -> PotStakes {
        var all = contributions
        for seat in Seat.allCases where all[seat] == nil {
            all[seat] = 0
        }
        return PotStakes(contributions: all, contenders: contenders, allIn: allIn)
    }

    @Test func aSplitAtShowdownDividesEqualHandsAndIgnoresSuits() throws {
        let table = TableFixture.table([1_000, 0, 1_000, 0], button: .north)
        let order = try TableFixture.order(
            for: table, holes: [.north: "2s 3d", .south: "2h 3c"], board: "Ac Kd Qh Js Th")
        let hand = try TableFixture.play(
            [.call, .check, .check, .check, .check, .check, .check, .check], from: table.dealHand(order: order))
        let result = try TableFixture.result(of: hand)
        #expect(result.awards.map(\.winners) == [[.south, .north]])
        #expect(result.stacks == [.south: 1_000, .west: 0, .north: 1_000, .east: 0])
    }

    /// 役の強さの見本（ペアとハイカード）。
    private enum Sample {
        case pair
        case high
    }

    private static func strength(_ sample: Sample) -> HandStrength {
        switch sample {
        case .pair:
            return HandEvaluator.strength(
                of: CardSet.of(
                    Deck.ordered.filter { $0.rank == .two }.prefix(2)
                        + Deck.ordered.filter { [.five, .seven, .nine].contains($0.rank) && $0.suit == .clubs }))
        case .high:
            return HandEvaluator.strength(
                of: CardSet.of(
                    Deck.ordered.filter {
                        [.two, .five, .seven, .nine, .jack].contains($0.rank)
                            && $0.suit == ($0.rank == .two ? .hearts : .clubs)
                    }))
        }
    }
}
