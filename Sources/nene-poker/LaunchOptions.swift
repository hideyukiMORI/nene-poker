import NeNePokerRender

/// 起動オプション（ARC-008: 境界で 1 度だけ検証し、型に変えてから中へ渡す）。
///
/// `--seed <0 以上の整数>` / `--theme <名前>` / `--view you|all` / `--move-interval <秒>` / `--result-pause <秒>`。
/// 移植元: NeNe Igo `Sources/nene-igo/LaunchOptions.swift`（コミット 2a46f6e）。札の見せ方（`--view`・FR-07a）を足した。
struct LaunchOptions {
    /// 乱数のシード。与えられなければ nil（起動時にシステムの乱数から決める）。
    let seed: UInt64?
    let theme: Theme
    /// 札の見せ方（既定はプレイヤー以外伏せる・REQUIREMENTS の Q5）。
    let view: ViewMode
    /// 1 行動の間隔（FR-11 の初期値は 1.0 秒）。
    let moveInterval: Duration
    /// ハンドと卓の結果を見せる時間（FR-11 の初期値は 3 秒）。
    let resultPause: Duration

    static let defaults = LaunchOptions(
        seed: nil, theme: .standard, view: .you, moveInterval: .milliseconds(1000), resultPause: .seconds(3))

    /// 起動オプションを読む（プログラム名を除いた引数）。
    static func parse(_ arguments: [String]) -> LaunchParsing {
        var options = defaults
        var rest = arguments[...]
        while let name = rest.popFirst() {
            guard let value = rest.popFirst() else {
                return .rejected("\(name) に値が無い")
            }
            guard let next = options.setting(name, value) else {
                return .rejected(
                    "読めないオプション: \(name) \(value)（--seed / --theme / --view / --move-interval / --result-pause / --version）"
                )
            }
            options = next
        }
        return .parsed(options)
    }

    /// 文字列で分岐するので `switch` ではなく `if` で書く（SWF-002: 全捕捉を書かない）。
    private func setting(_ name: String, _ value: String) -> LaunchOptions? {
        if name == "--seed" {
            return UInt64(value).map { with(LaunchChange(seed: $0)) }
        }
        if name == "--theme" {
            return Theme.named(value).map { with(LaunchChange(theme: $0)) }
        }
        if name == "--view" {
            return ViewMode.named(value).map { with(LaunchChange(view: $0)) }
        }
        if name == "--move-interval" {
            return Self.duration(value).map { with(LaunchChange(moveInterval: $0)) }
        }
        if name == "--result-pause" {
            return Self.duration(value).map { with(LaunchChange(resultPause: $0)) }
        }
        return nil
    }

    /// 0.05〜60 秒の秒数。
    private static func duration(_ text: String) -> Duration? {
        guard let seconds = Double(text), (0.05...60).contains(seconds) else {
            return nil
        }
        return .milliseconds(Int((seconds * 1000).rounded()))
    }

    private func with(_ change: LaunchChange) -> LaunchOptions {
        LaunchOptions(
            seed: change.seed ?? seed, theme: change.theme ?? theme, view: change.view ?? view,
            moveInterval: change.moveInterval ?? moveInterval, resultPause: change.resultPause ?? resultPause)
    }
}
