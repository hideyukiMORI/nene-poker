/// 1 つのポット（メインかサイド）の分け方（ADR 0007）。
public struct PotAward: Sendable, Hashable {
    /// ポットの額。
    public let amount: Int
    /// このポットを争えた席（降りておらず、この層まで出した席）。時計回りの順。
    public let contenders: [Seat]
    /// 取った席（スプリットなら複数）。親の次の席から時計回りの順。
    public let winners: [Seat]
    /// 取った席ごとの額（`winners` と同じ順）。端数は親の次の席から時計回りに 1 チップずつ。
    public let shares: [Int]
}
