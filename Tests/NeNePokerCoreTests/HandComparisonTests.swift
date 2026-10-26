import NeNePokerCore
import Testing

/// 手で作った札の組で、役の種類・比べるランク・2 人の比べ方を確かめる（FR-02a・ADR 0006）。
@Suite struct HandComparisonTests {
    @Test(arguments: HandCase.sevenCardExamples)
    func handMadeHandsHaveTheExpectedCategoryAndRanks(_ example: HandCase) throws {
        let strength = try Fixture.strength(example.cards)
        #expect(strength.category == example.category)
        #expect(strength.ranks == example.ranks)
    }

    @Test func theKickerDecidesBetweenEqualPairs() throws {
        let board = "Qs Qd 9c 5h 2s"
        #expect(try Fixture.strength(board + " Ah 3c") > Fixture.strength(board + " Kh 3c"))
    }

    @Test func aKickerBelowTheBoardDoesNotPlayAndTheHandsTie() throws {
        let board = "Ah Kd Qc Js 9h"
        #expect(try Fixture.strength(board + " 3c 2d") == Fixture.strength(board + " 4c 2h"))
    }

    @Test func theWheelIsTheLowestStraight() throws {
        let wheel = try Fixture.strength("Ah 2c 3d 4s 5h")
        let sixHigh = try Fixture.strength("2c 3d 4s 5h 6d")
        let aceHigh = try Fixture.strength("Tc Jd Qs Kh Ad")
        #expect(wheel < sixHigh)
        #expect(sixHigh < aceHigh)
        #expect(wheel.category == .straight)
    }

    @Test func theSteelWheelIsTheLowestStraightFlush() throws {
        let steelWheel = try Fixture.strength("Ah 2h 3h 4h 5h")
        #expect(steelWheel.category == .straightFlush)
        #expect(try steelWheel < Fixture.strength("2h 3h 4h 5h 6h"))
        #expect(try steelWheel > Fixture.strength("9c 9d 9h 9s Ac"))
    }

    @Test func noStraightWrapsAroundTheAce() throws {
        #expect(try Fixture.strength("Qh Kd Ac 2s 3h").category == .highCard)
    }

    @Test func categoriesOrderFromHighCardToStraightFlush() throws {
        let ladder = [
            "Ks Jd 9c 7h 5s", "Qs Qd 9c 7h 5s", "8s 8d 5c 5h Ks", "7s 7d 7c Ah Js", "Ah 2c 3d 4s 5h",
            "Ad 9d 7d 4d 2d", "Kc Kd Kh 3s 3c", "9c 9d 9h 9s Ac", "Ah 2h 3h 4h 5h",
        ]
        let strengths = try ladder.map(Fixture.strength)
        #expect(strengths.map(\.category) == HandCategory.allCases)
        #expect(strengths == strengths.sorted())
    }

    @Test func suitsNeverBreakATie() throws {
        #expect(try Fixture.strength("As Kd Qc Js 9h") == Fixture.strength("Ah Kc Qd Jh 9s"))
        #expect(try Fixture.strength("Ad 9d 7d 4d 2d") == Fixture.strength("Ac 9c 7c 4c 2c"))
    }

    @Test func twoPairComparesTheTopPairThenTheBottomPairThenTheKicker() throws {
        let acesAndTwos = try Fixture.strength("As Ad 2c 2h 3s")
        let kingsAndQueens = try Fixture.strength("Ks Kd Qc Qh As")
        let acesAndTwosFourKicker = try Fixture.strength("Ac Ah 2s 2d 4s")
        #expect(acesAndTwos > kingsAndQueens)
        #expect(acesAndTwosFourKicker > acesAndTwos)
    }
}
