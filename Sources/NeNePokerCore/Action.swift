/// 1 回の行動（FR-02・ADR 0007）。ベットとレイズの額は、そのストリートで出した額の合計（「いくらまで」）で表す。
///
/// 持っているチップを全部出す行動は、ベット・コール・レイズのどれに当たる場合も `allIn` の 1 つで表す（同じ意味を 2 つの形で書かない）。
public enum Action: Sendable, Hashable {
    case fold
    case check
    case call
    /// まだ誰も賭けていないストリートで、合計 n まで賭ける。
    case bet(Int)
    /// 賭けがあるストリートで、合計 n まで上げる。
    case raise(Int)
    case allIn
}
