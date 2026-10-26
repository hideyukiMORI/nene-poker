/// 出した額の段ごとに作った 1 つのポット（メインかサイド）。誰が取るかはまだ決めていない（ADR 0007）。
public struct PotLayer: Sendable, Hashable {
    /// ポットの額。
    public let amount: Int
    /// このポットを争える席（降りておらず、この段まで出した席）。親の次の席から時計回りの順。
    public let contenders: [Seat]
}
