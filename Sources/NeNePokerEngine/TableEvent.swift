import NeNePokerCore

/// 卓の出来事（HUD の LOG と席の下の 1 語の正本・ADR 0008）。
public enum TableEvent: Sendable, Hashable {
    /// 場札を開いた（フロップは 3 枚）。
    case dealt(Street, [Card])
    /// 席が行動した。`total` は行動の後にその席がこのストリートで出した額の合計。
    case acted(Seat, Action, total: Int)
}
