/// 札の文字列を読めなかった理由。
public enum CardDecodeRejection: Sendable, Hashable {
    /// 2 文字でない。
    case wrongLength
    /// 1 文字目がランクの記号（`2`〜`9` `T` `J` `Q` `K` `A`）でない。
    case unknownRank
    /// 2 文字目がスートの記号（`s` `h` `d` `c`）でない。
    case unknownSuit
}
