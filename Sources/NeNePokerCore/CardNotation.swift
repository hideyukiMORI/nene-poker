/// 札の文字列の表記の読み書き（唯一の経路・ADR 0005）。
///
/// 形はランク 1 文字とスート 1 文字。ランクは `2`〜`9`・`T`（10）・`J`・`Q`・`K`・`A`、スートは小文字の `s` `h` `d` `c`。例: `As`・`Td`。
/// 画面に出す文字もこの記号を使う（色と配置は Render が決める）。スート記号 `♠♥♦♣` は使わない（FR-07b）。
public enum CardNotation {
    /// 札を 2 文字にする。
    public static func encode(_ card: Card) -> String {
        String([symbol(of: card.rank), symbol(of: card.suit)])
    }

    /// 2 文字を札にする。読めなければ閉じた理由で返す（例外にしない）。
    public static func decode(_ text: String) -> CardDecodeOutcome {
        let characters = Array(text)
        guard characters.count == 2 else {
            return .rejected(.wrongLength)
        }
        guard let rank = Rank.allCases.first(where: { symbol(of: $0) == characters[0] }) else {
            return .rejected(.unknownRank)
        }
        guard let suit = Suit.allCases.first(where: { symbol(of: $0) == characters[1] }) else {
            return .rejected(.unknownSuit)
        }
        return .decoded(Card(rank: rank, suit: suit))
    }

    /// ランクの記号。
    public static func symbol(of rank: Rank) -> Character {
        Array("23456789TJQKA")[rank.rawValue]
    }

    /// スートの記号。
    public static func symbol(of suit: Suit) -> Character {
        switch suit {
        case .spades:
            return "s"
        case .hearts:
            return "h"
        case .diamonds:
            return "d"
        case .clubs:
            return "c"
        }
    }
}
