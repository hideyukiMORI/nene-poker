import NeNePokerCore

/// 1 卓の席とキャストの組（FR-07・ADR 0008）。メインの子は南の席に座る。
public struct Lineup: Sendable, Hashable {
    private let seats: [Persona]

    private init(seats: [Persona]) {
        self.seats = seats
    }

    /// 4 名を乱数で 4 席に並べる。南に座った 1 名がメインの子（卓ごとに乱数で選ぶ）。
    static func drawn(from cast: [Persona], using generator: inout some RandomNumberGenerator) -> Lineup {
        precondition(cast.count == 4, "卓は 4 人")
        return Lineup(seats: cast.shuffled(using: &generator))
    }

    /// 席のキャスト。
    public func persona(at seat: Seat) -> Persona {
        seats[seat.rawValue]
    }

    /// メインの子（南の席）。
    public var main: Persona {
        persona(at: .south)
    }
}
