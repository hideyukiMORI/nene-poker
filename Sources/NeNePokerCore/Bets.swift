/// 合法な行動のうち、額のあるもの（LegalActions の組み立ての中だけで使う）。
struct Bets: Sendable, Hashable {
    let bet: ClosedRange<Int>?
    let raise: ClosedRange<Int>?
    let allIn: Int?
}
