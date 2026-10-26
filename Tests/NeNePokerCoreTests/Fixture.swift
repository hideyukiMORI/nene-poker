import NeNePokerCore
import Testing

/// 手で作った札の読み込み（テストの中だけで使う）。読みは製品と同じ CardNotation の 1 経路。
enum Fixture {
    /// 空白で区切った札の表記（例 `As Kd 7c`）を読む。読めなければテストを止める。
    static func cards(_ text: String) throws -> [Card] {
        try text.split(separator: " ").map { word in
            switch CardNotation.decode(String(word)) {
            case .decoded(let card):
                return card
            case .rejected(let reason):
                Issue.record("読めない札 \(word): \(reason)")
                throw FixtureFailure.unreadable
            }
        }
    }

    /// 札の表記の集まりの役の強さ。
    static func strength(_ text: String) throws -> HandStrength {
        HandEvaluator.strength(of: CardSet.of(try cards(text)))
    }
}
