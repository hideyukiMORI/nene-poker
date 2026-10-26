import NeNePokerCore

/// 卓の 1 歩の出来事から、話す候補を優先度の高い順に作る（ADR 0012）。
enum BanterPrompts {
    /// 行動のあと: オールイン 70%・ベットとレイズ 30%・降りる 25%。しばらく誰も話していなければ（`idleRoll` が nil でない）、
    /// 降りていない誰か（`idleRoll` で選ぶ）が 50% で独り言。
    static func after(_ action: Action, by seat: Seat, in hand: Hand, idleRoll: Int?) -> [Prompt] {
        var prompts: [Prompt] = []
        switch action {
        case .allIn:
            prompts.append(Prompt(seat: seat, cue: .allIn, chance: 70))
        case .bet, .raise:
            prompts.append(Prompt(seat: seat, cue: .bet, chance: 30))
        case .fold:
            prompts.append(Prompt(seat: seat, cue: .fold, chance: 25))
        case .check, .call:
            break
        }
        let others = Seat.allCases.filter { [.active, .allIn].contains(hand.status(of: $0)) }
        if let idleRoll, !others.isEmpty {
            prompts.append(Prompt(seat: others[idleRoll % others.count], cue: .idle, chance: 50))
        }
        return prompts
    }

    /// ハンドの終わり: 飛んだ人（必ず）・取った人 60%・ショーダウンで負けた人 40%。
    static func after(_ result: HandResult, in hand: Hand) -> [Prompt] {
        let busted = Seat.allCases.filter { hand.status(of: $0) != .out && result.stacks[$0, default: 0] == 0 }
        var prompts = busted.map { Prompt(seat: $0, cue: .bust, chance: 100) }
        if let winner = result.awards.first?.winners.first {
            prompts.append(Prompt(seat: winner, cue: .won, chance: 60))
        }
        let losers = result.shown.keys.filter { seat in !result.awards.contains { $0.winners.contains(seat) } }
        prompts += Seat.allCases.filter(losers.contains).map { Prompt(seat: $0, cue: .lost, chance: 40) }
        return prompts
    }
}
