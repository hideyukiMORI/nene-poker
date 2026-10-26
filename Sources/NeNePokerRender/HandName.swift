import NeNePokerCore

/// 役の強さの名前（`PAIR OF QUEENS`・`FULL HOUSE, KINGS OVER THREES`）。Core の役判定の結果をそのまま言葉にするだけ（FR-10・ADR 0008）。
enum HandName {
    /// 役の名前。A を頭にしたストレートフラッシュは `ROYAL FLUSH`。
    static func of(_ strength: HandStrength) -> String {
        let ranks = strength.ranks
        let first = ranks.first ?? .two
        let second = ranks.dropFirst().first ?? .two
        switch strength.category {
        case .highCard:
            return single(first) + " HIGH"
        case .onePair:
            return "PAIR OF " + plural(first)
        case .twoPair:
            return "TWO PAIR, " + plural(first) + " AND " + plural(second)
        case .threeOfAKind:
            return "THREE " + plural(first)
        case .straight:
            return "STRAIGHT, " + single(first) + " HIGH"
        case .flush:
            return "FLUSH, " + single(first) + " HIGH"
        case .fullHouse:
            return "FULL HOUSE, " + plural(first) + " OVER " + plural(second)
        case .fourOfAKind:
            return "FOUR " + plural(first)
        case .straightFlush:
            return first == .ace ? "ROYAL FLUSH" : "STRAIGHT FLUSH, " + single(first) + " HIGH"
        }
    }

    /// 幅に入らなければ `, ` で 2 行に折る（略さない・画面仕様の Edge Cases）。
    static func wrapped(_ name: String, width: Int) -> [String] {
        let parts = name.split(separator: ",", maxSplits: 1)
        guard name.count > width, parts.count == 2 else {
            return [name]
        }
        return [String(parts[0]) + ",", String(parts[1].dropFirst())]
    }

    private static func single(_ rank: Rank) -> String {
        words[rank.rawValue].single
    }

    private static func plural(_ rank: Rank) -> String {
        words[rank.rawValue].plural
    }

    private static let words: [RankWords] = [
        RankWords(single: "TWO", plural: "TWOS"), RankWords(single: "THREE", plural: "THREES"),
        RankWords(single: "FOUR", plural: "FOURS"), RankWords(single: "FIVE", plural: "FIVES"),
        RankWords(single: "SIX", plural: "SIXES"), RankWords(single: "SEVEN", plural: "SEVENS"),
        RankWords(single: "EIGHT", plural: "EIGHTS"), RankWords(single: "NINE", plural: "NINES"),
        RankWords(single: "TEN", plural: "TENS"), RankWords(single: "JACK", plural: "JACKS"),
        RankWords(single: "QUEEN", plural: "QUEENS"), RankWords(single: "KING", plural: "KINGS"),
        RankWords(single: "ACE", plural: "ACES"),
    ]
}
