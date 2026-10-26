/// 格子の上の位置（左上が 0, 0）。
struct GridPoint: Sendable, Hashable {
    let column: Int
    let row: Int
}
