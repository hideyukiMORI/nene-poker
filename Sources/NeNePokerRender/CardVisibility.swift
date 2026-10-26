import NeNePokerCore
import NeNePokerEngine

/// どの席の札を表にするか（FR-07・FR-07a・ADR 0008）。表示だけの判断で、卓の進み方には関わらない。
///
/// - メインの子（南）の札は常に表
/// - 全員見える（ALL）なら全員の札が表、降りた札も控えめな地で残す
/// - プレイヤー以外伏せる（YOU）なら、ほかの席は裏。降りた札は空の枠。ショーダウンに残った人と、オールインで賭けが終わった後の残りの人はルールどおり表
/// - 全員が降りて終わったハンドの勝者の札は、YOU では見せない
enum CardVisibility {
    static func show(_ seat: Seat, in hand: Hand, view: ViewMode) -> CardShow {
        switch hand.status(of: seat) {
        case .out:
            return .none
        case .folded:
            return seat == .south || view == .all ? .foldedFaceUp : .empty
        case .active, .allIn:
            if seat == .south || view == .all || revealed(hand).contains(seat) {
                return .faceUp
            }
            return .faceDown
        }
    }

    /// ルールで表になる席: ショーダウンで見せた席と、行動できる人が 1 人以下で場札を開いていくだけになった後の残りの人。
    static func revealed(_ hand: Hand) -> Set<Seat> {
        let contenders = Seat.allCases.filter { [.active, .allIn].contains(hand.status(of: $0)) }
        switch hand.progress {
        case .complete(let result):
            return Set(result.shown.keys)
        case .awaitingDeal:
            let actors = contenders.filter { hand.status(of: $0) == .active }
            return contenders.count >= 2 && actors.count <= 1 ? Set(contenders) : []
        case .awaitingAction:
            return []
        }
    }
}
