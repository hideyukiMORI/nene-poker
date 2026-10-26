import NeNePokerCore
import Testing

@testable import NeNePokerEngine

/// 勝率の見積もり（FR-03・ADR 0011）。役の比較は Core の 1 経路を通るので、結果が決まっている局面では見積もりも決まる。
@Suite struct EquityTests {
    @Test func aRoyalFlushOnTheBoardSplitsEvenlyBetweenEveryone() throws {
        for opponents in 1...3 {
            var generator = SplitMix64(seed: UInt64(opponents))
            let view = SeatView(
                hole: try EquityTests.cards("7c 2d"), board: try EquityTests.cards("As Ks Qs Js Ts"),
                opponents: opponents)
            let equity = EquityEstimator.equity(view, samples: 200, using: &generator)
            #expect(equity == 100 / (opponents + 1))
        }
    }

    @Test func fourAcesWithNoPossibleStraightFlushNeverLose() throws {
        var generator = SplitMix64(seed: 3)
        let view = SeatView(
            hole: try EquityTests.cards("As Ah"), board: try EquityTests.cards("Ad Ac Kd 2s 7h"), opponents: 3)
        #expect(EquityEstimator.equity(view, samples: 500, using: &generator) == 100)
    }

    @Test func pocketAcesAreAboutEightyFivePercentAgainstOneRandomHandPreflop() throws {
        var generator = SplitMix64(seed: 4)
        let view = SeatView(hole: try EquityTests.cards("As Ah"), board: [], opponents: 1)
        let equity = EquityEstimator.equity(view, samples: 20_000, using: &generator)
        #expect(equity > 82 && equity < 88)
    }

    @Test func withoutOpponentsTheEquityIsOne() throws {
        var generator = SplitMix64(seed: 5)
        let view = SeatView(hole: try EquityTests.cards("7c 2d"), board: [], opponents: 0)
        #expect(EquityEstimator.equity(view, samples: 10, using: &generator) == 100)
    }

    private static func cards(_ text: String) throws -> [Card] {
        try text.split(separator: " ").map { word in
            guard case .decoded(let card) = CardNotation.decode(String(word)) else {
                Issue.record("読めない札 \(word)")
                throw EquityFixtureFailure.unreadable
            }
            return card
        }
    }
}
