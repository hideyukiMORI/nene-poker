import NeNePokerCore
import Testing

/// 役の種類ごとの札の組の数の公表値（一次資料から写した値・ADR 0006）。
///
/// 5 枚（52 枚から 5 枚の 2,598,960 通り）の出典（2026-10-26 に取得して写した）:
/// Henry Adams, Kelly Emmrich, Maria Gillespie, Shannon Golden, Rachel Pries, "Counting Rocks! An Introduction to Combinatorics",
/// arXiv:2108.04902v1（2021）, 3.8 節の "Poker Hands" の各役の "Number of hands"。https://arxiv.org/abs/2108.04902v1
/// 出典はロイヤルフラッシュ（4）とそれ以外のストレートフラッシュ（36）を分けて書く。
///
/// 7 枚（52 枚から 7 枚の 133,784,560 通り。最良の 5 枚の役で数える）の出典（2026-10-26 に取得して写した）:
/// Christopher Williamson, "Extremal poker hand rankings: why the standard 52 card deck and a 3044 card deck are special",
/// arXiv:2511.06145v1（2025）, Table 1 の "Standard deck r = 13" の列（showdown frequency: 7 枚の中の 5 枚で作れる役のうち、
/// いちばん強いものの種類で数えた数）。https://arxiv.org/abs/2511.06145v1
/// 出典はロイヤルフラッシュを分けずにストレートフラッシュ（41,584）に含める。
struct PublishedHandCounts: Sendable, CustomTestStringConvertible {
    let category: HandCategory
    let count: Int

    var testDescription: String {
        "\(category) = \(count)"
    }

    /// 5 枚。ストレートフラッシュは出典のロイヤルフラッシュ 4 とそれ以外の 36 の和。
    static let fiveCards: [PublishedHandCounts] = [
        PublishedHandCounts(category: .straightFlush, count: 4 + 36),
        PublishedHandCounts(category: .fourOfAKind, count: 624),
        PublishedHandCounts(category: .fullHouse, count: 3_744),
        PublishedHandCounts(category: .flush, count: 5_108),
        PublishedHandCounts(category: .straight, count: 10_200),
        PublishedHandCounts(category: .threeOfAKind, count: 54_912),
        PublishedHandCounts(category: .twoPair, count: 123_552),
        PublishedHandCounts(category: .onePair, count: 1_098_240),
        PublishedHandCounts(category: .highCard, count: 1_302_540),
    ]

    /// 5 枚のロイヤルフラッシュ（A を頭にしたストレートフラッシュ）の数。
    static let fiveCardRoyalFlushes = 4

    /// 7 枚。
    static let sevenCards: [PublishedHandCounts] = [
        PublishedHandCounts(category: .straightFlush, count: 41_584),
        PublishedHandCounts(category: .fourOfAKind, count: 224_848),
        PublishedHandCounts(category: .fullHouse, count: 3_473_184),
        PublishedHandCounts(category: .flush, count: 4_047_644),
        PublishedHandCounts(category: .straight, count: 6_180_020),
        PublishedHandCounts(category: .threeOfAKind, count: 6_461_620),
        PublishedHandCounts(category: .twoPair, count: 31_433_400),
        PublishedHandCounts(category: .onePair, count: 58_627_800),
        PublishedHandCounts(category: .highCard, count: 23_294_460),
    ]
}
