/// 札の見せ方（FR-07a・ADR 0008）。表示だけの状態で、Core と Engine はこの型を知らない（ADR 0004）。
public enum ViewMode: Sendable, Hashable, CaseIterable {
    /// プレイヤー（メインの子）以外の札を伏せる（既定・REQUIREMENTS の Q5）。
    case you
    /// 全員の札を見せる。
    case all

    /// `v` を押したときの次のモード。
    public var toggled: ViewMode {
        switch self {
        case .you:
            return .all
        case .all:
            return .you
        }
    }

    /// 起動オプション `--view` の名前（`you` / `all`）から。読めなければ nil。
    public static func named(_ name: String) -> ViewMode? {
        allCases.first { Wording.viewName($0).lowercased() == name.lowercased() }
    }
}
