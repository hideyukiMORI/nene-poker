/// 席の札の見せ方（ADR 0008）。
enum CardShow: Sendable, Hashable {
    /// 配られていない（飛んだ席）。札を描かない。
    case none
    /// 表。
    case faceUp
    /// 裏。
    case faceDown
    /// 降りた札を控えめな地で表に（全員見える・メインの子）。
    case foldedFaceUp
    /// 降りた札を描かず空の枠に（プレイヤー以外伏せる）。
    case empty
}
