/// 手番の席が取れる行動の一覧（唯一の合法性の経路・ARC-001・ADR 0007）。Engine はここから選び、Hand の適用もここで確かめる。
public struct LegalActions: Sendable, Hashable {
    /// 降りられるか（賭けに向き合っているとき）。
    public let fold: Bool
    /// チェックできるか。
    public let check: Bool
    /// コールで足す額（コールできないなら nil）。
    public let call: Int?
    /// ベットの合計額の範囲（ベットできないなら nil）。上限は全部のチップより 1 少ない（全部はオールイン）。
    public let bet: ClosedRange<Int>?
    /// レイズの合計額の範囲（レイズできないなら nil）。
    public let raise: ClosedRange<Int>?
    /// オールインしたときのこのストリートの合計額（できないなら nil）。
    public let allIn: Int?

    init(fold: Bool, check: Bool, call: Int?, bets: Bets) {
        self.fold = fold
        self.check = check
        self.call = call
        self.bet = bets.bet
        self.raise = bets.raise
        self.allIn = bets.allIn
    }

    /// 行動が合法なら nil、合法でなければ理由。
    public func rejection(of action: Action) -> ActionRejection? {
        switch action {
        case .fold:
            return fold ? nil : .foldWithoutBet
        case .check:
            return check ? nil : .checkFacingBet
        case .call:
            return call == nil ? .callNotPossible : nil
        case .bet(let amount):
            return LegalActions.rejection(of: amount, in: bet, closed: .betNotOpen)
        case .raise(let amount):
            return LegalActions.rejection(of: amount, in: raise, closed: .raiseNotOpen)
        case .allIn:
            return allIn == nil ? .allInWouldReopen : nil
        }
    }

    private static func rejection(of amount: Int, in range: ClosedRange<Int>?, closed: ActionRejection)
        -> ActionRejection?
    {
        guard let range else {
            return closed
        }
        if range.contains(amount) {
            return nil
        }
        return amount < range.lowerBound ? .amountBelowMinimum : .amountIsAllIn
    }
}
