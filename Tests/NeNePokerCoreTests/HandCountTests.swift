import NeNePokerCore
import Testing

/// 52 枚から 5 枚・7 枚の全部の組の役を数え、公表値（PublishedHandCounts）と完全に一致させる（FR-02a・ADR 0006）。
@Suite struct HandCountTests {
    private static let singles = Deck.ordered.map { CardSet.of([$0]) }

    @Test func everyFiveCardHandIsCountedLikeThePublishedTable() {
        let tally = HandCountTests.tally(size: 5)
        for expected in PublishedHandCounts.fiveCards {
            #expect(tally.counts[expected.category.rawValue] == expected.count, "\(expected.category)")
        }
        #expect(tally.total == 2_598_960)
        #expect(tally.aceHighStraightFlushes == PublishedHandCounts.fiveCardRoyalFlushes)
    }

    @Test func everySevenCardHandIsCountedLikeThePublishedTable() {
        let tally = HandCountTests.tally(size: 7)
        for expected in PublishedHandCounts.sevenCards {
            #expect(tally.counts[expected.category.rawValue] == expected.count, "\(expected.category)")
        }
        #expect(tally.total == 133_784_560)
    }

    /// 52 枚から size 枚の全部の組を辞書順に回して、役の種類ごとに数える。
    private static func tally(size: Int) -> Tally {
        var indices = Array(0..<size)
        var tally = Tally()
        repeat {
            let set = indices.reduce(CardSet.empty) { $0.union(singles[$1]) }
            let strength = HandEvaluator.strength(of: set)
            tally.counts[strength.category.rawValue] += 1
            tally.total += 1
            if strength.category == .straightFlush, strength.ranks == [.ace] {
                tally.aceHighStraightFlushes += 1
            }
        } while advance(&indices, limit: singles.count)
        return tally
    }

    /// 組の添字を辞書順で 1 つ進める。最後の組の次は false。
    private static func advance(_ indices: inout [Int], limit: Int) -> Bool {
        var position = indices.count - 1
        while position >= 0, indices[position] == limit - indices.count + position {
            position -= 1
        }
        guard position >= 0 else {
            return false
        }
        indices[position] += 1
        for next in (position + 1)..<indices.count {
            indices[next] = indices[next - 1] + 1
        }
        return true
    }
}
