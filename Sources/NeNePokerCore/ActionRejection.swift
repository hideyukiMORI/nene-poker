/// 行動が合法でない理由（ADR 0007）。
public enum ActionRejection: Sendable, Hashable {
    /// 行動を待っていない（場札を開く前・ハンドの終わり）。
    case noActionPending
    /// 賭けに向き合っていないので降りる意味が無い（チェックできる）。
    case foldWithoutBet
    /// 賭けに向き合っているのでチェックできない。
    case checkFacingBet
    /// コールする額が無いか、コールが全部のチップに届く（オールインで表す）。
    case callNotPossible
    /// もう賭けがあるのでベットではなくレイズになる。
    case betNotOpen
    /// レイズできない（賭けが無い・すでに行動して、満額のレイズに向き合っていない）。
    case raiseNotOpen
    /// 最小のベット額・最小のレイズ額に届かない。
    case amountBelowMinimum
    /// 額が全部のチップに届く（オールインで表す）。
    case amountIsAllIn
    /// オールインがレイズになるが、レイズの権利が開いていない。
    case allInWouldReopen
}
