/// ブラインドの上がり方（FR-04・ADR 0007）。決まったハンド数ごとに次の段階へ上がり、最後の段階のあとは同じ段階のまま。
public struct BlindSchedule: Sendable, Hashable {
    /// 段階の並び（1 段階目から）。
    public let levels: [BlindLevel]
    /// 1 段階のハンド数。
    public let handsPerLevel: Int

    private init(levels: [BlindLevel], handsPerLevel: Int) {
        self.levels = levels
        self.handsPerLevel = handsPerLevel
    }

    /// ビッグブラインドの並びから作る。スモールブラインドはビッグの半分（切り捨て）。
    /// 空・ビッグが 2 未満・ビッグが下がる・1 段階のハンド数が 1 未満なら nil。
    public static func make(bigBlinds: [Int], handsPerLevel: Int) -> BlindSchedule? {
        let levels = bigBlinds.enumerated().compactMap { index, big in
            BlindLevel.make(number: index + 1, smallBlind: big / 2, bigBlind: big)
        }
        let rising = zip(levels, levels.dropFirst()).allSatisfy { $0.bigBlind <= $1.bigBlind }
        guard !levels.isEmpty, levels.count == bigBlinds.count, rising, handsPerLevel >= 1 else {
            return nil
        }
        return BlindSchedule(levels: levels, handsPerLevel: handsPerLevel)
    }

    /// 1 から始まるハンド番号のときの段階。
    public func level(forHand number: Int) -> BlindLevel {
        let index = min(max(number - 1, 0) / handsPerLevel, levels.count - 1)
        return levels[index]
    }
}
