import NeNePokerCore
import NeNePokerEngine
import Testing

@testable import NeNePokerRender

/// どの席の札を表にするか（FR-07・FR-07a・画面仕様の States and Interactions）。
@Suite struct CardVisibilityTests {
    @Test func theMainPlayersCardsAreAlwaysFaceUp() {
        for series in Steps.all where series.hand.status(of: .south) != .out {
            for view in ViewMode.allCases {
                let show = CardVisibility.show(.south, in: series.hand, view: view)
                #expect(show == .faceUp || show == .foldedFaceUp)
            }
        }
    }

    @Test func otherLiveSeatsAreFaceDownInYouAndFaceUpInAllWhileBettingContinues() throws {
        let betting = try #require(
            Steps.all.first { series in
                guard case .awaitingAction = series.hand.progress else {
                    return false
                }
                return series.hand.status(of: .north) == .active
            })
        #expect(CardVisibility.show(.north, in: betting.hand, view: .you) == .faceDown)
        #expect(CardVisibility.show(.north, in: betting.hand, view: .all) == .faceUp)
    }

    @Test func foldedCardsAreAnEmptyFrameInYouAndADimFaceInAll() throws {
        let folded = try #require(
            Steps.all.first { series in Seat.allCases.dropFirst().contains { series.hand.status(of: $0) == .folded } })
        let seat = try #require(Seat.allCases.dropFirst().first { folded.hand.status(of: $0) == .folded })
        #expect(CardVisibility.show(seat, in: folded.hand, view: .you) == .empty)
        #expect(CardVisibility.show(seat, in: folded.hand, view: .all) == .foldedFaceUp)
    }

    @Test func seatsLeftAtShowdownAreFaceUpInBothViews() throws {
        let showdown = try #require(
            Steps.all.first { series in
                guard case .complete(let result) = series.hand.progress else {
                    return false
                }
                return result.ending == .showdown && result.shown.keys.contains { $0 != .south }
            })
        guard case .complete(let result) = showdown.hand.progress else {
            return
        }
        for seat in result.shown.keys {
            #expect(CardVisibility.show(seat, in: showdown.hand, view: .you) == .faceUp)
        }
    }

    @Test func theWinnerOfAnUncontestedHandKeepsTheirCardsHiddenInYou() throws {
        let uncontested = try #require(
            Steps.all.first { series in
                guard case .complete(let result) = series.hand.progress else {
                    return false
                }
                return result.ending == .uncontested && result.awards.first?.winners.first != .south
            })
        guard case .complete(let result) = uncontested.hand.progress, let winner = result.awards.first?.winners.first
        else {
            return
        }
        #expect(CardVisibility.show(winner, in: uncontested.hand, view: .you) == .faceDown)
        #expect(CardVisibility.show(winner, in: uncontested.hand, view: .all) == .faceUp)
    }
}
