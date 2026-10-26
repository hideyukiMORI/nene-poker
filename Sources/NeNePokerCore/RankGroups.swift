/// ランクごとの枚数で分けたランクの集まり（13 ビットずつ）。役判定の中だけで使う（ADR 0005）。
struct RankGroups {
    /// 1 枚以上あるランク。
    let present: Int
    /// 4 枚あるランク。
    let quads: Int
    /// ちょうど 3 枚あるランク。
    let trips: Int
    /// ちょうど 2 枚あるランク。
    let pairs: Int
}
