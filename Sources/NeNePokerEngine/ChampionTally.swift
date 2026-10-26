/// キャストごとの通算の優勝の数（FR-04）。
public struct ChampionTally: Sendable, Hashable {
    private let wins: [String: Int]

    private init(wins: [String: Int]) {
        self.wins = wins
    }

    /// 1 卓も終わっていない。
    public static let zero = ChampionTally(wins: [:])

    /// その名前のキャストの優勝の数。
    public func wins(of persona: Persona) -> Int {
        wins[persona.name, default: 0]
    }

    /// 終わった卓の数。
    public var finishedTables: Int {
        wins.values.reduce(0, +)
    }

    /// 1 卓の優勝を足した通算。
    func recording(_ persona: Persona) -> ChampionTally {
        var next = wins
        next[persona.name, default: 0] += 1
        return ChampionTally(wins: next)
    }
}
