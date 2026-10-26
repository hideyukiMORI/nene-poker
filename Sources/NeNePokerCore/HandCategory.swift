/// 役の種類（弱い順）。ロイヤルフラッシュは A を頭にしたストレートフラッシュで、別の種類にしない（ADR 0005）。
public enum HandCategory: Int, Sendable, Hashable, CaseIterable, Comparable {
    case highCard = 0
    case onePair = 1
    case twoPair = 2
    case threeOfAKind = 3
    case straight = 4
    case flush = 5
    case fullHouse = 6
    case fourOfAKind = 7
    case straightFlush = 8

    /// 弱い順に比べる。
    public static func < (lhs: HandCategory, rhs: HandCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// 比べるときに見るランクの数（ストレートは頭の 1 枚・フルハウスはスリーカードとペアの 2 つ等）。
    var comparedRankCount: Int {
        switch self {
        case .highCard, .flush:
            return 5
        case .onePair:
            return 4
        case .twoPair, .threeOfAKind:
            return 3
        case .fullHouse, .fourOfAKind:
            return 2
        case .straight, .straightFlush:
            return 1
        }
    }
}
