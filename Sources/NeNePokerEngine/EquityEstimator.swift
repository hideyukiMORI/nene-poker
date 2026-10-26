import NeNePokerCore

/// 自前の勝率の見積もり（FR-03・ADR 0011）: 残りの場札と相手の手札を乱数で埋め、Core の役判定で比べるモンテカルロ。回数で打ち切る。
///
/// 見積もりは行動を選ぶためだけに使い、画面には出さない（施主は言っていない）。役の比較は Core の `HandEvaluator` と `HandStrength` の 1 経路。
public enum EquityEstimator {
    /// 手札と場札と相手の人数から、勝ちを 1・n 人の引き分けを 1/n と数えた平均の百分率（0〜100・切り捨て）。相手が 0 人なら 100。
    ///
    /// 浮動小数点を使わず整数で数える（1 回の勝ちを 12 点、n 人の引き分けを 12/n 点。12 は 1〜4 人のどれでも割り切れる）。
    /// `Double` の `rounded()` や `squareRoot()` は libm を呼び、標準モジュールを import しない実行ファイルではリンクできない（ADR 0001 の X-i・ADR 0011）。
    public static func equity(_ view: SeatView, samples: Int, using generator: inout some RandomNumberGenerator) -> Int
    {
        guard view.opponents > 0, samples > 0 else {
            return 100
        }
        let known = CardSet.of(view.hole + view.board)
        var pool = Deck.ordered.filter { !known.contains($0) }
        let missing = 5 - view.board.count
        let needed = missing + 2 * view.opponents
        precondition(needed <= pool.count, "配る札が足りる")
        let boardSet = CardSet.of(view.board)
        let holeSet = CardSet.of(view.hole)
        var total = 0
        for _ in 0..<samples {
            for index in 0..<needed {
                pool.swapAt(index, Int.random(in: index..<pool.count, using: &generator))
            }
            let fullBoard = boardSet.union(CardSet.of(Array(pool[0..<missing])))
            let mine = HandEvaluator.strength(of: holeSet.union(fullBoard))
            var best = true
            var ties = 1
            for opponent in 0..<view.opponents {
                let start = missing + 2 * opponent
                let theirs = HandEvaluator.strength(of: fullBoard.union(CardSet.of(Array(pool[start..<(start + 2)]))))
                if theirs > mine {
                    best = false
                    break
                }
                if theirs == mine {
                    ties += 1
                }
            }
            total += best ? 12 / ties : 0
        }
        return total * 100 / (samples * 12)
    }
}
