/// 52 枚の札の 1 枚（ADR 0005）。ランクとスートのどの組も 1 枚ずつあるので、どの組からも作れる。
///
/// 文字列の表記（`As` `Td`）の読み書きは `CardNotation` の 1 経路だけ。
public struct Card: Sendable, Hashable {
    /// ランク。
    public let rank: Rank
    /// スート。
    public let suit: Suit

    /// ランクとスートから札を作る。
    public init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }

    /// `CardSet` の中のビットの位置（スートごとに 16 ビットの区画・その中の下位 13 ビットがランク）。
    var bitIndex: Int {
        suit.rawValue * 16 + rank.rawValue
    }
}
