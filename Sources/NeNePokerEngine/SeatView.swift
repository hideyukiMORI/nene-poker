import NeNePokerCore

/// 1 人の席から見える札（自分の手札・場札・まだ降りていない相手の人数）。勝率の見積もりの入力（ADR 0011）。
///
/// 相手の手札は入れない（見えない札を AI に見せない）。
public struct SeatView: Sendable, Hashable {
    public let hole: [Card]
    public let board: [Card]
    public let opponents: Int

    /// 組を作る。
    public init(hole: [Card], board: [Card], opponents: Int) {
        self.hole = hole
        self.board = board
        self.opponents = opponents
    }

    /// ハンドの中の席から見える札。
    public static func of(_ seat: Seat, in hand: Hand) -> SeatView {
        let opponents = Seat.allCases.filter { other in
            other != seat && [.active, .allIn].contains(hand.status(of: other))
        }
        return SeatView(hole: hand.holeCards(of: seat), board: hand.board, opponents: opponents.count)
    }
}
