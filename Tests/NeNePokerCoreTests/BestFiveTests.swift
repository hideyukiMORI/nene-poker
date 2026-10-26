import NeNePokerCore
import Testing

/// 7 枚の役の強さが、7 枚から選べる 21 通りの 5 枚の役の強さの最大と一致すること（最良の 5 枚を選んでいる・FR-02a・ADR 0006）。
///
/// 5 枚の役の強さは全数の公表値で確かめてある（HandCountTests）ので、それを基準に 6 枚・7 枚の判定を確かめる。
@Suite struct BestFiveTests {
    @Test(arguments: [6, 7])
    func theStrengthOfMoreCardsIsTheBestOfItsFiveCardSubsets(_ size: Int) {
        var generator = SplitMix64(seed: 0x5EED_0007 &+ UInt64(size))
        for _ in 0..<20_000 {
            let cards = Array(Deck.dealingOrder(using: &generator).prefix(size))
            let best = BestFiveTests.subsets(of: cards, size: 5).map { HandEvaluator.strength(of: CardSet.of($0)) }
                .max()
            #expect(HandEvaluator.strength(of: CardSet.of(cards)) == best)
        }
    }

    /// 札の並びから size 枚を選ぶ全部の組。
    private static func subsets(of cards: [Card], size: Int) -> [[Card]] {
        guard size > 0 else {
            return [[]]
        }
        guard let first = cards.first else {
            return []
        }
        let rest = Array(cards.dropFirst())
        return subsets(of: rest, size: size - 1).map { [first] + $0 } + subsets(of: rest, size: size)
    }
}
