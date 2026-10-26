/// 役の強さ（役の種類と、比べる順のランク）。2 人の役の比較はこの型の比較の 1 経路だけ（ARC-001・ADR 0005）。
///
/// 値は 1 つの整数に詰めて持つ: 役の種類を上位に、比べる順のランクを 4 ビットずつ下へ並べる。整数の大小がそのまま役の強さの大小になる。
public struct HandStrength: Sendable, Hashable, Comparable {
    private let score: Int

    private init(score: Int) {
        self.score = score
    }

    /// 役の種類と、比べる順のランクを 4 ビットずつ（ランクの添字＋1）上から詰めた値から作る。ランクの数は役の種類ごとに決まっている。
    static func packed(_ category: HandCategory, _ ranks: Int, count: Int) -> HandStrength {
        precondition(count == category.comparedRankCount, "役の種類と比べるランクの数が合わない")
        return HandStrength(score: category.rawValue << 20 | ranks << (4 * (5 - count)))
    }

    /// 役の種類。
    public var category: HandCategory {
        HandCategory.allCases[score >> 20]
    }

    /// 比べる順のランク。ストレートとストレートフラッシュは頭の 1 枚（ホイールは 5）、フルハウスはスリーカードとペア、
    /// ツーペアは上のペア・下のペア・キッカー、ほかは組の札のランクのあとにキッカーを強い順に。
    public var ranks: [Rank] {
        (0..<category.comparedRankCount).compactMap { slot in Rank(rawValue: ((score >> (16 - 4 * slot)) & 0xF) - 1) }
    }

    /// 弱い順に比べる。
    public static func < (lhs: HandStrength, rhs: HandStrength) -> Bool {
        lhs.score < rhs.score
    }
}
