/// 札のスート（ADR 0005）。並びは表記と 4 色のデッキの順（スペード・ハート・ダイヤ・クラブ）で、役の強さには関わらない。
public enum Suit: Int, Sendable, Hashable, CaseIterable {
    case spades = 0
    case hearts = 1
    case diamonds = 2
    case clubs = 3
}
