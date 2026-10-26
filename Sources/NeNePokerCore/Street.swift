/// 4 つのベッティングラウンド（FR-02）。
public enum Street: Sendable, Hashable, CaseIterable {
    case preflop
    case flop
    case turn
    case river

    /// このストリートの時点で開いている場札の枚数。
    public var boardCount: Int {
        switch self {
        case .preflop:
            return 0
        case .flop:
            return 3
        case .turn:
            return 4
        case .river:
            return 5
        }
    }

    /// 次のストリート。リバーの次は無い。
    public var next: Street? {
        switch self {
        case .preflop:
            return .flop
        case .flop:
            return .turn
        case .turn:
            return .river
        case .river:
            return nil
        }
    }
}
