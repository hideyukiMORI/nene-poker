import NeNePokerCore

/// 合法な行動から乱数で 1 つ選ぶ打ち手（テストの中だけで使う）。額は合法な範囲から一様に選ぶ。
/// オールインは 20 回に 1 回だけ選ぶ（毎回の候補に入れると卓が数ハンドで終わり、長い卓の場面を通らない）。
enum RandomActor {
    /// 合法な行動の一覧から 1 つ。
    static func choose(from legal: LegalActions, using generator: inout SplitMix64) -> Action {
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

    /// ハンドを終わりまで乱数で打つ。選んだ行動を actions に足し、進むごとに観察する。
    static func playOut(
        _ hand: Hand, using generator: inout SplitMix64, actions: inout [Action], observe: (Hand) -> Void
    ) -> Hand {
        var current = hand
        while true {
            observe(current)
            switch current.progress {
            case .awaitingAction:
                guard let legal = current.legalActions else {
                    preconditionFailure("行動を待つときは合法な一覧がある")
                }
                let action = choose(from: legal, using: &generator)
                guard case .applied(let next) = current.apply(action) else {
                    preconditionFailure("合法な一覧から選んだ行動は必ず適用できる")
                }
                actions.append(action)
                current = next
            case .awaitingDeal:
                current = current.dealNextStreet()
            case .complete:
                return current
            }
        }
    }
}
