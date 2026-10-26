/// ハンドの進み具合（ADR 0007）。
public enum HandProgress: Sendable, Hashable {
    /// この席の行動を待っている。
    case awaitingAction(Seat)
    /// 賭けが終わり、このストリートの場札を開くのを待っている（`Hand.dealNextStreet()`）。
    case awaitingDeal(Street)
    /// ハンドが終わった。
    case complete(HandResult)
}
