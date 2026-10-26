/// ブラインドの 1 段階（FR-04・ADR 0007）。
public struct BlindLevel: Sendable, Hashable {
    /// 1 から始まる段階の番号。
    public let number: Int
    /// スモールブラインド。
    public let smallBlind: Int
    /// ビッグブラインド。最小のベット額と、ストリートの最初の最小のレイズ幅にもなる（Robert's Rules の第 14 節の 2）。
    public let bigBlind: Int

    private init(number: Int, smallBlind: Int, bigBlind: Int) {
        self.number = number
        self.smallBlind = smallBlind
        self.bigBlind = bigBlind
    }

    /// 段階を作る。番号が 1 以上・0 < スモール ≦ ビッグでなければ nil。
    public static func make(number: Int, smallBlind: Int, bigBlind: Int) -> BlindLevel? {
        guard number >= 1, smallBlind > 0, smallBlind <= bigBlind else {
            return nil
        }
        return BlindLevel(number: number, smallBlind: smallBlind, bigBlind: bigBlind)
    }
}
