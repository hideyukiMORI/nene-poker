@testable import NeNePokerRender

/// 画面のテストで描くテーマと配置の組。
struct Layout: Sendable, CustomStringConvertible {
    var theme: Theme
    var compact = false

    var description: String {
        theme.name + (compact ? " compact" : " large")
    }

    /// 12 テーマ × 2 つの配置。
    static let all: [Layout] = Theme.catalog.flatMap { [Layout(theme: $0), Layout(theme: $0, compact: true)] }
}
