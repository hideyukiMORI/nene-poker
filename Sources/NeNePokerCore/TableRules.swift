/// 卓の決まり（初期のチップとブラインドの上がり方・FR-04・ADR 0007）。
public struct TableRules: Sendable, Hashable {
    /// 卓の始めに各席に配るチップ。
    public let startingStack: Int
    /// ブラインドの上がり方。
    public let schedule: BlindSchedule

    private init(startingStack: Int, schedule: BlindSchedule) {
        self.startingStack = startingStack
        self.schedule = schedule
    }

    /// 決まりを作る。初期のチップが 1 段階目のビッグブラインド未満なら nil。
    public static func make(startingStack: Int, schedule: BlindSchedule) -> TableRules? {
        guard let first = schedule.levels.first, startingStack >= first.bigBlind else {
            return nil
        }
        return TableRules(startingStack: startingStack, schedule: schedule)
    }
}
