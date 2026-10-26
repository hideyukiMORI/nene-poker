/// 卓の中の置き場所（卓の枠の中の左上からの位置・ADR 0008・0012）。大の配置と縮小版で 1 つずつ。
struct FeltPlan: Sendable, Hashable {
    let north: GridPoint
    let west: GridPoint
    let east: GridPoint
    let south: GridPoint
    let board: GridPoint
    let potRow: Int
    /// 南の札を小さい札（4 桁 × 1 行）で描くか（縮小版）。
    let compact: Bool

    /// 大の配置（卓の枠 76 × 22）。
    static let large = FeltPlan(
        north: GridPoint(column: 26, row: 0), west: GridPoint(column: 2, row: 7), east: GridPoint(column: 50, row: 7),
        south: GridPoint(column: 18, row: 12), board: GridPoint(column: 25, row: 8), potRow: 10, compact: false)
    /// 縮小版（卓の枠 50 × 19）。
    static let compactPlan = FeltPlan(
        north: GridPoint(column: 14, row: 0), west: GridPoint(column: 0, row: 4), east: GridPoint(column: 26, row: 4),
        south: GridPoint(column: 8, row: 11), board: GridPoint(column: 12, row: 8), potRow: 9, compact: true)
}
