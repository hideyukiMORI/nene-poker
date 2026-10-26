/// ポットとサイドポットの作り方と分け方（唯一の経路・ARC-001・ADR 0007）。
///
/// 出典は Robert's Rules of Poker（Version 11）の第 3 節: サイドポットとメインのポットは別々に分ける（Ties の 5(d)）。
/// 同じ強さの役で分けて割り切れないチップは、親から時計回りで最初の手が受け取る（Ties の 5(a)）。1 人が受け取る端数は 1 チップまで（Ties の 4）。
public enum PotDivision {
    /// 各席の出した額・争える席（降りていない席）・争える席の役の強さ（相手のいない層は見ない）・親の席から分け方を決める。
    /// 争える席がちょうど 1 つなら、役の強さは要らない（`strengths` は空でよい）。
    public static func divide(
        contributions: [Seat: Int], contenders: Set<Seat>, strengths: [Seat: HandStrength], button: Seat
    )
        -> [PotAward]
    {
        let order = button.clockwiseFromNext
        let levels = Array(Set(contributions.values.filter { $0 > 0 })).sorted()
        var awards: [PotAward] = []
        var previous = 0
        for level in levels {
            let amount = contributions.values.reduce(0) { $0 + min($1, level) - min($1, previous) }
            let eligible = order.filter { contenders.contains($0) && contributions[$0, default: 0] >= level }
            previous = level
            if let last = awards.last, last.contenders == eligible || eligible.isEmpty {
                awards[awards.count - 1] = award(
                    amount: last.amount + amount, contenders: last.contenders, strengths, order)
            } else {
                awards.append(award(amount: amount, contenders: eligible, strengths, order))
            }
        }
        return awards
    }

    /// 1 つのポットを、争える席のうちいちばん強い役の席で分ける。
    private static func award(amount: Int, contenders: [Seat], _ strengths: [Seat: HandStrength], _ order: [Seat])
        -> PotAward
    {
        precondition(!contenders.isEmpty, "最初の層には必ず争える席がある（降りていない席の出した額が下限になる）")
        precondition(contenders.count == 1 || contenders.allSatisfy { strengths[$0] != nil }, "争う席には役の強さが要る")
        let best = contenders.count == 1 ? nil : contenders.compactMap { strengths[$0] }.max()
        let winners = order.filter { contenders.contains($0) && (best == nil || strengths[$0] == best) }
        let share = amount / winners.count
        let odd = amount % winners.count
        let shares = winners.indices.map { share + ($0 < odd ? 1 : 0) }
        return PotAward(amount: amount, contenders: contenders, winners: winners, shares: shares)
    }
}
