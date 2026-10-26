/// 1 ハンドで使う 52 枚の山札（ADR 0005）。シャッフルは乱数源を引数で受け取る（ARC-007）。
public enum Deck {
    /// 52 枚を、スートの順・ランクの弱い順に並べたもの。
    public static let ordered: [Card] = Suit.allCases.flatMap { suit in
        Rank.allCases.map { Card(rank: $0, suit: suit) }
    }

    /// 52 枚を、渡された乱数源で切った配る順。同じ状態の乱数源からは同じ順になる。
    public static func dealingOrder(using generator: inout some RandomNumberGenerator) -> [Card] {
        ordered.shuffled(using: &generator)
    }
}
