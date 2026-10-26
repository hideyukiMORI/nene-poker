/// キャストの打ち方の性格（FR-06・ADR 0011）。確率は百分率の整数で持つ（乱数との比べ方を 1 つにする）。
public struct PlayStyle: Sendable, Hashable {
    /// 勝率の見積もりの回数。
    public let samples: Int
    /// 手の選び方の緩さ: ポットオッズに足りない勝率でも、この百分率ぶんまではコールする（負なら厳しく選ぶ）。
    public let looseness: Int
    /// 攻撃性: 強い手でベット・レイズする確率の百分率。ベット・レイズの額（ポットの 50% から 50%＋攻撃性まで）にも効く。
    public let aggression: Int
    /// ブラフの頻度: 弱い手でベット・レイズする確率の百分率。
    public let bluffing: Int

    private init(samples: Int, looseness: Int, aggression: Int, bluffing: Int) {
        self.samples = samples
        self.looseness = looseness
        self.aggression = aggression
        self.bluffing = bluffing
    }

    /// 性格を作る。回数が 1 以上・緩さが -50〜50・攻撃性とブラフが 0〜100 でなければ nil。
    public static func make(samples: Int, looseness: Int, aggression: Int, bluffing: Int) -> PlayStyle? {
        guard samples >= 1, (-50...50).contains(looseness), (0...100).contains(aggression), (0...100).contains(bluffing)
        else {
            return nil
        }
        return PlayStyle(samples: samples, looseness: looseness, aggression: aggression, bluffing: bluffing)
    }

    /// 強い手とみなす勝率の百分率（緩い人ほど薄い手でも強いとみなす）。
    var valueEquity: Int {
        55 - looseness / 2
    }

    /// ベット・レイズの額のポットに対する百分率の範囲。
    var sizing: ClosedRange<Int> {
        50...(50 + aggression)
    }
}
