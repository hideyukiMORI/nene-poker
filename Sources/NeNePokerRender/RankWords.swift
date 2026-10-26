/// ランクの英語の名前（1 枚と複数）。
struct RankWords: Sendable, Hashable {
    let single: String
    let plural: String
}
