import NeNePokerCore

/// 画面に出す文言。文言のリテラルを持つのはここだけ（キャラクターの名前と顔は Engine の性格が持つ）。
///
/// 英語の大文字の ASCII にしてある。罫線とブロックは `FrameGlyphs` が持つ（ADR 0008）。札の記号は Core の `CardNotation` の 1 経路から取る。
/// 移植元: NeNe Igo `Sources/NeNeIgoRender/Wording.swift`（コミット 2a46f6e）の形。中身はポーカーの文言に書き直した。
enum Wording {
    static let title = "NENE//POKER"
    static let match = "MATCH"
    static let stacks = "STACKS"
    static let log = "LOG"
    static let result = "RESULT"
    static let lastLabel = "LAST "
    static let potLabel = "POT "
    static let sideLabel = " + SIDE "
    static let out = "OUT"
    static let dealer = "(D)"
    static let smallBlind = "SB"
    static let bigBlind = "BB"
    static let cardBack = "##"
    static let emptyCard = "--"
    static let quitKey = "[q]"
    static let quitName = " QUIT   "
    static let viewKey = "[v]"
    static let viewName = " VIEW: "
    static let themeKey = "[t]"
    static let themeName = " THEME: "
    static let winner = "WINNER  "
    static let takes = "TAKES   "
    static let split = "SPLIT   "
    static let champion = "CHAMPION  "
    static let tablesWon = "TABLES WON  "
    static let nextTable = "NEXT TABLE  "

    static func tableNumber(_ number: Int) -> String {
        padded(number, width: 3)
    }

    static func headerTable(_ number: Int) -> String {
        "TABLE " + padded(number, width: 3)
    }

    static func headerHand(_ number: Int) -> String {
        "HAND " + padded(number, width: 3)
    }

    static func seed(_ seed: UInt64) -> String {
        let hex = String(seed, radix: 16, uppercase: true)
        return "SEED 0x" + String(repeating: "0", count: max(16 - hex.count, 0)) + hex
    }

    static func colors(_ mode: ColorMode) -> String {
        switch mode {
        case .trueColor:
            return "24BIT"
        case .palette256:
            return "256C"
        }
    }

    /// `--view` と画面の名前（`YOU` / `ALL`）。
    static func viewName(_ mode: ViewMode) -> String {
        switch mode {
        case .you:
            return "YOU"
        case .all:
            return "ALL"
        }
    }

    static func street(_ street: Street) -> String {
        switch street {
        case .preflop:
            return "PREFLOP"
        case .flop:
            return "FLOP"
        case .turn:
            return "TURN"
        case .river:
            return "RIVER"
        }
    }

    /// 札の 2 文字（`As` `Td`）。Core の表記の 1 経路をそのまま使う。
    static func card(_ card: Card) -> String {
        CardNotation.encode(card)
    }

    /// 席の下の 1 語（`FOLD` `CHECK` `CALL 80` `BET 80` `RAISE 240` `ALL-IN`）。
    static func actionWord(_ action: Action, total: Int) -> String {
        switch action {
        case .fold:
            return "FOLD"
        case .check:
            return "CHECK"
        case .call:
            return "CALL " + chips(total)
        case .bet:
            return "BET " + chips(total)
        case .raise:
            return "RAISE " + chips(total)
        case .allIn:
            return "ALL-IN"
        }
    }

    /// LOG の動詞（`folds` `checks` `calls 80` `bets 80` `raises to 240` `all-in 1,500`）。
    static func actionLog(_ action: Action, total: Int) -> String {
        switch action {
        case .fold:
            return "folds"
        case .check:
            return "checks"
        case .call:
            return "calls " + chips(total)
        case .bet:
            return "bets " + chips(total)
        case .raise:
            return "raises to " + chips(total)
        case .allIn:
            return "all-in " + chips(total)
        }
    }

    /// 3 桁区切りのチップの額（`1,240`）。
    static func chips(_ amount: Int) -> String {
        let digits = Array(String(amount))
        var out = ""
        for (index, digit) in digits.enumerated() {
            if index > 0, (digits.count - index) % 3 == 0 {
                out += ","
            }
            out.append(digit)
        }
        return out
    }

    /// STACKS の席の印（南はメインの子なので `YOU`）。
    static func seatTag(_ seat: Seat) -> String {
        switch seat {
        case .south:
            return "YOU"
        case .west:
            return "W"
        case .north:
            return "N"
        case .east:
            return "E"
        }
    }

    /// 左を空白で埋めて `width` 桁にする。
    static func rightAligned(_ text: String, to width: Int) -> String {
        String(repeating: " ", count: max(width - text.count, 0)) + text
    }

    static func seconds(_ value: Int) -> String {
        "\(value)s"
    }

    static func tooSmall(need size: ScreenSize) -> String {
        "TERMINAL TOO SMALL (NEED \(size.columns)x\(size.rows))"
    }

    static func padded(_ number: Int, width: Int) -> String {
        let digits = String(number)
        return String(repeating: "0", count: max(width - digits.count, 0)) + digits
    }

    /// 右を空白で埋めて `width` 桁にする（長ければ切る）。
    static func fitted(_ text: String, to width: Int) -> String {
        String(text.prefix(width)) + String(repeating: " ", count: max(width - text.count, 0))
    }
}
