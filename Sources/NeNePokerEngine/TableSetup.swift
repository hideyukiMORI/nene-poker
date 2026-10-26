import NeNePokerCore

/// 製品の卓の決まり（初期のチップとブラインドの上がり方・FR-04）。値は AI を入れて 1 卓の長さを測って決めた（ADR 0011）。
public enum TableSetup {
    /// 初期のチップ 1,500・10 ハンドごとに上がるブラインド。
    public static let standard: TableRules = {
        let bigBlinds = [20, 40, 80, 120, 160, 200, 300, 400, 600, 800, 1_000, 1_500, 2_000, 3_000]
        guard let schedule = BlindSchedule.make(bigBlinds: bigBlinds, handsPerLevel: 10),
            let rules = TableRules.make(startingStack: 1_500, schedule: schedule)
        else {
            preconditionFailure("製品の卓の決まりは作れる")
        }
        return rules
    }()
}
