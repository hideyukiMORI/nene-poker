/// ハンドの終わり方（ADR 0007）。
public enum HandEnding: Sendable, Hashable {
    /// 1 人を残して全員が降りた。札は見せない。
    case uncontested
    /// リバーのあとに残った人が札を見せて役を比べた。
    case showdown
}
