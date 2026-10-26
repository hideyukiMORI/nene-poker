/// 札の文字列を読んだ結果。
public enum CardDecodeOutcome: Sendable, Hashable {
    case decoded(Card)
    case rejected(CardDecodeRejection)
}
