/// 合法な行動の一覧と、行動の適用（ADR 0007）。
///
/// 出典は Robert's Rules of Poker（Version 11）の第 14 節 No-limit rules:
/// 最小のベットはビッグブラインド（2）。レイズはそのストリートの直前のベットかレイズの幅以上（3）。
/// すでに行動した人は、満額のレイズに向き合っていなければ、足りないオールインに対してレイズできない（3）。
/// 足りないオールインが重なって、その人から見て満額のレイズの幅に届けば、レイズの権利が開く（4）。
extension Hand {
    /// 手番の席が取れる行動（行動を待っていなければ nil）。
    public var legalActions: LegalActions? {
        guard result == nil, let seat = turn else {
            return nil
        }
        let index = seat.rawValue
        let committed = streetBets[index]
        let total = committed + stacks[index]
        let toCall = max(0, currentBet - committed)
        let reopened = actedAt[index].map { currentBet - $0 >= lastRaiseSize } ?? true
        let bet = currentBet == 0 && level.bigBlind < total ? level.bigBlind...(total - 1) : nil
        let minimumRaise = currentBet + lastRaiseSize
        let raise = currentBet > 0 && reopened && minimumRaise < total ? minimumRaise...(total - 1) : nil
        let allIn = total <= currentBet || reopened ? total : nil
        return LegalActions(
            fold: toCall > 0, check: toCall == 0, call: toCall > 0 && toCall < stacks[index] ? toCall : nil,
            bets: Bets(bet: bet, raise: raise, allIn: allIn))
    }

    /// 手番の席の行動を適用する。合法でなければ理由を返す（例外にしない）。
    public func apply(_ action: Action) -> HandApplyOutcome {
        guard let legal = legalActions, let seat = turn else {
            return .rejected(.noActionPending)
        }
        if let rejection = legal.rejection(of: action) {
            return .rejected(rejection)
        }
        var next = self
        next.perform(action, by: seat)
        next.actedAt[seat.rawValue] = next.currentBet
        next.lastActions[seat.rawValue] = action
        return .applied(next.settled(after: seat))
    }

    /// 合法と確かめた行動で、チップと賭けの状態を変える。
    private mutating func perform(_ action: Action, by seat: Seat) {
        let index = seat.rawValue
        switch action {
        case .fold:
            statuses[index] = .folded
        case .check:
            break
        case .call:
            put(currentBet - streetBets[index], from: seat)
        case .bet(let amount), .raise(let amount):
            raiseTo(amount, by: seat)
        case .allIn:
            raiseTo(streetBets[index] + stacks[index], by: seat)
        }
    }

    /// このストリートの合計を amount にする。いまの賭けを超えれば賭けを上げ、満額の幅ならレイズの幅も更新する。
    private mutating func raiseTo(_ amount: Int, by seat: Seat) {
        put(amount - streetBets[seat.rawValue], from: seat)
        guard amount > currentBet else {
            return
        }
        let increase = amount - currentBet
        if increase >= lastRaiseSize {
            lastRaiseSize = increase
        }
        currentBet = amount
    }
}
