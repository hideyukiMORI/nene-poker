/// ハンドの結果（ADR 0007）。
public struct HandResult: Sendable, Hashable {
    /// 終わり方。
    public let ending: HandEnding
    /// ポットごとの分け方（メインが先、サイドが後）。
    public let awards: [PotAward]
    /// ショーダウンで札を見せた席と役の強さ（降りずに残った席。終わり方が uncontested なら空）。
    public let shown: [Seat: HandStrength]
    /// 分けたあとの各席のチップ。
    public let stacks: [Seat: Int]
}
