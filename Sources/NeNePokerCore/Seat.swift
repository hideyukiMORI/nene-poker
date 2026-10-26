/// 卓の 4 つの席（ADR 0007）。並びは時計回りで、親（ディーラーボタン）と行動の順はこの向きに進む（FR-01）。
///
/// 画面の配置（南が手前）は Render が決める。Core にとっては時計回りの順番だけが意味を持つ。
public enum Seat: Int, Sendable, Hashable, CaseIterable {
    case south = 0
    case west = 1
    case north = 2
    case east = 3

    /// 時計回りで次の席。
    public var next: Seat {
        switch self {
        case .south:
            return .west
        case .west:
            return .north
        case .north:
            return .east
        case .east:
            return .south
        }
    }

    /// この席の次から時計回りに 1 周した 4 席（この席が最後）。
    public var clockwiseFromNext: [Seat] {
        [next, next.next, next.next.next, self]
    }
}
