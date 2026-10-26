/// 見た目の選択（テーマ・札の見せ方）と端末の性質。持ち主は合成ルートで、Render は受け取って描くだけ。
public struct DisplayOptions: Sendable, Hashable {
    public let theme: Theme
    public let view: ViewMode
    public let traits: TerminalTraits

    /// 組を作る。
    public init(theme: Theme, view: ViewMode, traits: TerminalTraits) {
        self.theme = theme
        self.view = view
        self.traits = traits
    }

    /// テーマを次へ替えた組（`t`）。
    public var cyclingTheme: DisplayOptions {
        DisplayOptions(theme: theme.next, view: view, traits: traits)
    }

    /// 札の見せ方を切り替えた組（`v`）。
    public var togglingView: DisplayOptions {
        DisplayOptions(theme: theme, view: view.toggled, traits: traits)
    }
}
