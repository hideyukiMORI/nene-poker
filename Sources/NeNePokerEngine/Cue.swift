/// 発言のきっかけになる出来事（話す本人から見た向き・ADR 0012）。
public enum Cue: Sendable, Hashable, CaseIterable {
    /// 卓の始まり。
    case start
    /// 自分がベットかレイズした。
    case bet
    /// 自分が降りた。
    case fold
    /// 自分がオールインした。
    case allIn
    /// 自分がポットを取った。
    case won
    /// ショーダウンで負けた。
    case lost
    /// チップが 0 になって卓から抜けた。
    case bust
    /// 卓で優勝した。
    case champion
    /// しばらく誰も話していない。
    case idle

    /// その出来事を言うときの気分。
    public var mood: Mood {
        switch self {
        case .bet, .won, .champion:
            return .smug
        case .start, .fold, .allIn, .idle:
            return .neutral
        case .lost, .bust:
            return .grim
        }
    }
}
