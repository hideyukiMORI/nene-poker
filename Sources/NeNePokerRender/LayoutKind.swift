/// 端末の大きさで選ぶ配置（2 段・FR-16）。移植元: NeNe Igo `Sources/NeNeIgoRender/LayoutKind.swift`（コミット 2a46f6e）。
enum LayoutKind: Sendable, Hashable {
    /// 大の配置が入る
    case large
    /// 縮小版が入る
    case compact
    /// それより小さい: 1 行の文言だけ
    case tooSmall

    static func fitting(_ size: ScreenSize) -> LayoutKind {
        if fits(ScreenLayout.large.size, in: size) {
            return .large
        }
        if fits(ScreenLayout.compact.size, in: size) {
            return .compact
        }
        return .tooSmall
    }

    private static func fits(_ need: ScreenSize, in size: ScreenSize) -> Bool {
        size.columns >= need.columns && size.rows >= need.rows
    }
}
