import NeNePokerCore

/// 勝率の見積もり＋ポットオッズ＋性格で、Core の合法な行動の一覧から 1 つ選ぶ（FR-03・FR-06・ADR 0011）。
///
/// 賭けに向き合っているとき: 強い手なら攻撃性の確率でレイズ、ポットオッズ（コールの額 ÷ コールした後のポット）に勝率＋緩さが届けばコール、
/// 届かなければブラフの確率でレイズ、それ以外は降りる。向き合っていないとき: 強い手なら攻撃性の確率でベット、ブラフの確率でベット、それ以外はチェック。
/// 選んだ行動は一覧の中のものだけで、額は一覧の範囲に収め、範囲を超えるならオールインにする。
public enum ActionChooser {
    /// 手番の席の行動。行動を待っていないハンドで呼ぶのはプログラムの欠陥。
    public static func choose(in hand: Hand, style: PlayStyle, using generator: inout some RandomNumberGenerator)
        -> Action
    {
        guard case .awaitingAction(let seat) = hand.progress, let legal = hand.legalActions else {
            preconditionFailure("行動を待つハンドでだけ選ぶ")
        }
        let percent = EquityEstimator.equity(SeatView.of(seat, in: hand), samples: style.samples, using: &generator)
        let strong = percent >= style.valueEquity && roll(style.aggression, &generator)
        let bluff = roll(style.bluffing, &generator)
        let target = hand.highestBet + hand.pot * Int.random(in: style.sizing, using: &generator) / 100
        if legal.check {
            return strong || bluff ? aggressive(legal, to: target) ?? .check : .check
        }
        if strong, let raise = aggressive(legal, to: target) {
            return raise
        }
        if let toCall = legal.call ?? legal.allIn.map({ $0 - hand.streetBet(of: seat) }) {
            let odds = toCall * 100 / max(hand.pot + toCall, 1)
            if percent + style.looseness >= odds {
                return legal.call == nil ? .allIn : .call
            }
        }
        if bluff, let raise = aggressive(legal, to: target) {
            return raise
        }
        return .fold
    }

    /// 合計 `target` までのベットかレイズ（範囲に収める・上限を超えるならオールイン）。どれもできなければ nil。
    private static func aggressive(_ legal: LegalActions, to target: Int) -> Action? {
        if let bet = legal.bet {
            return target > bet.upperBound ? .allIn : .bet(min(max(target, bet.lowerBound), bet.upperBound))
        }
        if let raise = legal.raise {
            return target > raise.upperBound ? .allIn : .raise(min(max(target, raise.lowerBound), raise.upperBound))
        }
        if let allIn = legal.allIn, legal.call == nil || allIn > 0 {
            return .allIn
        }
        return nil
    }

    /// 百分率の確率で真。
    private static func roll(_ percent: Int, _ generator: inout some RandomNumberGenerator) -> Bool {
        Int.random(in: 0..<100, using: &generator) < percent
    }
}
