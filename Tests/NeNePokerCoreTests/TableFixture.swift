import Testing

@testable import NeNePokerCore

/// 手作りの卓とハンドの組み立て（テストの中だけで使う）。
enum TableFixture {
    /// ブラインド 10 / 20 の 1 段階だけの決まり（初期のチップは 1,000）。
    static let rules: TableRules = {
        guard let schedule = BlindSchedule.make(bigBlinds: [20], handsPerLevel: 1_000),
            let rules = TableRules.make(startingStack: 1_000, schedule: schedule)
        else {
            preconditionFailure("テストの決まりは作れる")
        }
        return rules
    }()

    /// 席のチップを南・西・北・東の順に並べた卓。
    static func table(_ stacks: [Int], button: Seat = .south, hand: Int = 1) -> Table {
        Table.arranged(rules: rules, button: button, stacks: stacks, handNumber: hand)
    }

    /// 配る順。手札は席ごとに 2 枚、場札は 5 枚まで。残りは並べた山札の順で埋める。
    static func order(for table: Table, holes: [Seat: String], board: String = "") throws -> [Card] {
        let dealt = table.button.clockwiseFromNext.filter { table.stack(of: $0) > 0 }
        var hands: [Seat: [Card]] = [:]
        for seat in dealt {
            hands[seat] = try holes[seat].map(Fixture.cards) ?? []
        }
        let boardCards = try board.isEmpty ? [] : Fixture.cards(board)
        let named = hands.values.flatMap { $0 } + boardCards
        var spare = Deck.ordered.filter { !named.contains($0) }
        var order: [Card] = []
        for round in 0..<2 {
            for seat in dealt {
                let cards = hands[seat] ?? []
                order.append(round < cards.count ? cards[round] : spare.removeFirst())
            }
        }
        for slot in 0..<5 {
            order.append(slot < boardCards.count ? boardCards[slot] : spare.removeFirst())
        }
        return order + spare
    }

    /// 打てるはずの行動を順に適用する。拒まれたらテストを止める。場札を待つ所では場札を開く。
    static func play(_ actions: [Action], from hand: Hand) throws -> Hand {
        var current = hand
        for action in actions {
            current = dealing(current)
            switch current.apply(action) {
            case .applied(let next):
                current = next
            case .rejected(let reason):
                Issue.record("合法なはずの \(action) が \(reason) で拒まれた")
                throw FixtureFailure.rejected
            }
        }
        return current
    }

    /// 場札を待つ間は開き続ける。
    static func dealing(_ hand: Hand) -> Hand {
        var current = hand
        while case .awaitingDeal = current.progress {
            current = current.dealNextStreet()
        }
        return current
    }

    /// 終わったハンドの結果（終わっていなければテストを止める）。
    static func result(of hand: Hand) throws -> HandResult {
        guard case .complete(let result) = dealing(hand).progress else {
            Issue.record("ハンドが終わっていない: \(hand.progress)")
            throw FixtureFailure.rejected
        }
        return result
    }
}
