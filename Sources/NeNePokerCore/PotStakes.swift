/// ポットを作るのに要る、各席の出した額と、争える席と、そのうちオールインした席（ADR 0007）。
public struct PotStakes: Sendable, Hashable {
    /// 各席がこのハンドで出した額の合計。
    public let contributions: [Seat: Int]
    /// 争える席（降りていない席）。
    public let contenders: Set<Seat>
    /// 争える席のうち、オールインした席。
    public let allIn: Set<Seat>

    /// 組を作る。オールインした席は争える席に含まれる。
    public init(contributions: [Seat: Int], contenders: Set<Seat>, allIn: Set<Seat>) {
        self.contributions = contributions
        self.contenders = contenders
        self.allIn = allIn.intersection(contenders)
    }
}
