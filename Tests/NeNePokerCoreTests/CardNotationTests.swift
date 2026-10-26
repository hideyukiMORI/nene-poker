import NeNePokerCore
import Testing

/// 札の表記の読み書きと、山札（FR-02・FR-05・ADR 0005）。
@Suite struct CardNotationTests {
    @Test func everyCardRoundTripsThroughItsNotation() {
        for card in Deck.ordered {
            #expect(CardNotation.decode(CardNotation.encode(card)) == .decoded(card))
        }
        #expect(Set(Deck.ordered.map(CardNotation.encode)).count == 52)
    }

    @Test func notationUsesTenAsTAndLowercaseSuits() {
        #expect(CardNotation.encode(Card(rank: .ten, suit: .diamonds)) == "Td")
        #expect(CardNotation.encode(Card(rank: .ace, suit: .spades)) == "As")
        #expect(CardNotation.encode(Card(rank: .two, suit: .clubs)) == "2c")
    }

    @Test func unreadableNotationIsRejectedWithAReason() {
        #expect(CardNotation.decode("10d") == .rejected(.wrongLength))
        #expect(CardNotation.decode("") == .rejected(.wrongLength))
        #expect(CardNotation.decode("1d") == .rejected(.unknownRank))
        #expect(CardNotation.decode("AS") == .rejected(.unknownSuit))
        #expect(CardNotation.decode("A\u{2660}") == .rejected(.unknownSuit))
    }

    @Test func theOrderedDeckHoldsEveryCardOnce() {
        #expect(Deck.ordered.count == 52)
        #expect(Set(Deck.ordered).count == 52)
        #expect(CardSet.of(Deck.ordered).count == 52)
    }

    @Test func theSameSeedShufflesTheSameOrderAndADifferentSeedDoesNot() {
        var first = SplitMix64(seed: 42)
        var second = SplitMix64(seed: 42)
        var other = SplitMix64(seed: 43)
        let deck = Deck.dealingOrder(using: &first)
        #expect(deck == Deck.dealingOrder(using: &second))
        #expect(deck != Deck.dealingOrder(using: &other))
        #expect(Set(deck).count == 52)
    }

    @Test func aCardSetKeepsEachCardOnce() throws {
        let cards = try Fixture.cards("As As Kd")
        let set = CardSet.of(cards)
        #expect(set.count == 2)
        #expect(set.cards.count == 2)
        #expect(set.contains(Card(rank: .king, suit: .diamonds)))
        #expect(!set.contains(Card(rank: .king, suit: .spades)))
    }
}
