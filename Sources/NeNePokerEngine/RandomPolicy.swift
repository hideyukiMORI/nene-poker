import NeNePokerCore

/// 合法な行動から乱数で 1 つ選ぶ打ち手（Phase 3-3 の仮の AI・ADR 0008）。Core の合法な一覧から選ぶので、選んだ行動は必ず合法。
///
/// 額は合法な範囲から一様に選ぶ。オールインは 20 回に 1 回だけ選ぶ（毎回の候補に入れると卓が数ハンドで終わる）。
public enum RandomPolicy {
    /// 合法な行動の一覧から 1 つ。
    public static func choose(from legal: LegalActions, using generator: inout some RandomNumberGenerator) -> Action {
        var options: [Action] = []
        if legal.fold {
            options.append(.fold)
        }
        if legal.check {
            options.append(.check)
        }
        if legal.call != nil {
            options += [.call, .call]
        }
        if let bet = legal.bet {
            options.append(.bet(Int.random(in: bet, using: &generator)))
        }
        if let raise = legal.raise {
            options.append(.raise(Int.random(in: raise, using: &generator)))
        }
        let shove = legal.allIn != nil && Int.random(in: 0..<20, using: &generator) == 0
        return shove ? .allIn : options.randomElement(using: &generator) ?? .allIn
    }
}
