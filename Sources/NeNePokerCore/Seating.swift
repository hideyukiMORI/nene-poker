/// 1 ハンドの席の配置（親とブラインド・段階・番号）。Table が決めて Hand に渡す（ADR 0007）。
struct Seating: Sendable, Hashable {
    let button: Seat
    let smallBlind: Seat
    let bigBlind: Seat
    let level: BlindLevel
    let number: Int
}
