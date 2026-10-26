/// 行動を適用した結果。
public enum HandApplyOutcome: Sendable, Hashable {
    case applied(Hand)
    case rejected(ActionRejection)
}
