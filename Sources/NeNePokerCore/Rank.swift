/// 札のランク（ADR 0005）。生の値は 2 を 0 とする 0〜12 の添字で、`CardSet` のビットの位置になる。
///
/// A はいちばん強い。ストレートの 5-4-3-2-A（ホイール）でだけ 1 としても数えるが、それは役判定の中の扱いで、ランクの比較は変えない。
public enum Rank: Int, Sendable, Hashable, CaseIterable, Comparable {
    case two = 0
    case three = 1
    case four = 2
    case five = 3
    case six = 4
    case seven = 5
    case eight = 6
    case nine = 7
    case ten = 8
    case jack = 9
    case queen = 10
    case king = 11
    case ace = 12

    /// 弱い順に比べる。
    public static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
