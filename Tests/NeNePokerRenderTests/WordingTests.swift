import NeNePokerCore
import Testing

@testable import NeNePokerRender

/// 役の名前・チップの額・行動の語（FR-10・画面仕様の Edge Cases）。
@Suite struct WordingTests {
    @Test func handNamesComeFromTheCoreStrength() {
        #expect(WordingTests.name("Qs Qd 9c 5h 2s") == "PAIR OF QUEENS")
        #expect(WordingTests.name("Kc Kd Kh 3s 3c") == "FULL HOUSE, KINGS OVER THREES")
        #expect(WordingTests.name("As Ks Qs Js Ts") == "ROYAL FLUSH")
        #expect(WordingTests.name("Ah 2c 3d 4s 5h") == "STRAIGHT, FIVE HIGH")
        #expect(WordingTests.name("8s 8d 5c 5h Ks") == "TWO PAIR, EIGHTS AND FIVES")
        #expect(WordingTests.name("Ks Jd 9c 7h 5s") == "KING HIGH")
        #expect(WordingTests.name("9c 9d 9h 9s Ac") == "FOUR NINES")
        #expect(WordingTests.name("6h 7h 8h 9h Th") == "STRAIGHT FLUSH, TEN HIGH")
        #expect(WordingTests.name("Ad 9d 7d 4d 2d") == "FLUSH, ACE HIGH")
        #expect(WordingTests.name("7s 7d 7c Ah Js") == "THREE SEVENS")
    }

    @Test func chipsUseThousandsSeparators() {
        #expect(Wording.chips(0) == "0")
        #expect(Wording.chips(999) == "999")
        #expect(Wording.chips(1_240) == "1,240")
        #expect(Wording.chips(1_000_000) == "1,000,000")
    }

    @Test func actionWordsMatchTheScreenSpecification() {
        #expect(Wording.actionWord(.fold, total: 0) == "FOLD")
        #expect(Wording.actionWord(.call, total: 80) == "CALL 80")
        #expect(Wording.actionWord(.raise(240), total: 240) == "RAISE 240")
        #expect(Wording.actionWord(.allIn, total: 1_500) == "ALL-IN")
        #expect(Wording.actionLog(.bet(80), total: 80) == "bets 80")
    }

    @Test func viewModesCanBeNamedAndToggle() {
        #expect(ViewMode.named("you") == .you)
        #expect(ViewMode.named("ALL") == .all)
        #expect(ViewMode.named("everyone") == nil)
        #expect(ViewMode.you.toggled == .all && ViewMode.all.toggled == .you)
    }

    private static func name(_ text: String) -> String {
        let cards = text.split(separator: " ").compactMap { word -> Card? in
            guard case .decoded(let card) = CardNotation.decode(String(word)) else {
                return nil
            }
            return card
        }
        return HandName.of(HandEvaluator.strength(of: CardSet.of(cards)))
    }
}
