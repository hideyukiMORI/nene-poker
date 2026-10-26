/// 5〜7 枚の札から、最良の 5 枚の役の強さを求める（唯一の役判定・FR-02a・ADR 0005）。
///
/// 21 通りの 5 枚を作って比べる代わりに、スートごとのランクの集まり（13 ビット）とランクごとの枚数の集まりから、最良の 5 枚を直接決める。
/// 7 枚以下では、フラッシュ（5 枚が同じスート）とフォーカード・フルハウスは同時に起きない（同じスートの 5 枚の外に札が 2 枚しか無い）ので、
/// フラッシュを先に見てよい。正しさは全数の公表値との一致と、21 通りの比較との一致で確かめる（テスト）。
/// 勝率の見積もりが何度も呼ぶので、配列を作らずに整数のビットだけで決める。
public enum HandEvaluator {
    /// 札の集まり（5〜7 枚）の最良の 5 枚の役の強さ。
    public static func strength(of cards: CardSet) -> HandStrength {
        precondition((5...7).contains(cards.count), "役判定は 5〜7 枚")
        let spades = cards.ranks(of: .spades)
        let hearts = cards.ranks(of: .hearts)
        let diamonds = cards.ranks(of: .diamonds)
        let clubs = cards.ranks(of: .clubs)
        let flush = flushRanks(spades, hearts, diamonds, clubs)
        if flush != 0 {
            if let top = straightTop(flush) {
                return .packed(.straightFlush, top.rawValue + 1, count: 1)
            }
            return .packed(.flush, highest(flush, count: 5), count: 5)
        }
        let quads = spades & hearts & diamonds & clubs
        let atLeastThree = (spades & hearts & (diamonds | clubs)) | (diamonds & clubs & (spades | hearts))
        let atLeastTwo = (spades & (hearts | diamonds | clubs)) | (hearts & (diamonds | clubs)) | (diamonds & clubs)
        let groups = RankGroups(
            present: spades | hearts | diamonds | clubs, quads: quads, trips: atLeastThree & ~quads,
            pairs: atLeastTwo & ~atLeastThree)
        return strength(of: groups)
    }

    /// フラッシュの無い札の集まりの役の強さ。
    private static func strength(of groups: RankGroups) -> HandStrength {
        if groups.quads != 0 {
            let quad = topBit(groups.quads)
            return .packed(.fourOfAKind, (quad + 1) << 4 | highest(groups.present & ~(1 << quad), count: 1), count: 2)
        }
        if groups.trips != 0 {
            let trip = topBit(groups.trips)
            let pairable = (groups.trips & ~(1 << trip)) | groups.pairs
            if pairable != 0 {
                return .packed(.fullHouse, (trip + 1) << 4 | (topBit(pairable) + 1), count: 2)
            }
        }
        if let top = straightTop(groups.present) {
            return .packed(.straight, top.rawValue + 1, count: 1)
        }
        if groups.trips != 0 {
            let trip = topBit(groups.trips)
            return .packed(.threeOfAKind, (trip + 1) << 8 | highest(groups.present & ~(1 << trip), count: 2), count: 3)
        }
        if groups.pairs.nonzeroBitCount >= 2 {
            let pairs = highest(groups.pairs, count: 2)
            let used = groups.pairs & (1 << ((pairs >> 4) - 1) | 1 << ((pairs & 0xF) - 1))
            return .packed(.twoPair, pairs << 4 | highest(groups.present & ~used, count: 1), count: 3)
        }
        if groups.pairs != 0 {
            let pair = topBit(groups.pairs)
            return .packed(.onePair, (pair + 1) << 12 | highest(groups.present & ~(1 << pair), count: 3), count: 4)
        }
        return .packed(.highCard, highest(groups.present, count: 5), count: 5)
    }

    /// 5 枚以上あるスートのランクの集まり。無ければ 0（7 枚以下では 5 枚以上のスートは高々 1 つ）。
    private static func flushRanks(_ spades: Int, _ hearts: Int, _ diamonds: Int, _ clubs: Int) -> Int {
        if spades.nonzeroBitCount >= 5 {
            return spades
        }
        if hearts.nonzeroBitCount >= 5 {
            return hearts
        }
        if diamonds.nonzeroBitCount >= 5 {
            return diamonds
        }
        return clubs.nonzeroBitCount >= 5 ? clubs : 0
    }

    /// ランクの集まり（13 ビット）の中の 5 枚続きの頭のランク。A は 5-4-3-2-A の 1 としても数える。無ければ nil。
    static func straightTop(_ ranks: Int) -> Rank? {
        let extended = ranks << 1 | (ranks >> Rank.ace.rawValue & 1)
        let runs = extended & extended >> 1 & extended >> 2 & extended >> 3 & extended >> 4
        guard runs != 0 else {
            return nil
        }
        return Rank(rawValue: topBit(runs) + 3)
    }

    /// いちばん上の立っているビットの位置（0 でない値に限る）。
    private static func topBit(_ value: Int) -> Int {
        Int.bitWidth - 1 - value.leadingZeroBitCount
    }

    /// ランクの集まりの強い順の count 個を、4 ビットずつ（ランクの添字＋1）上から詰めた値。
    private static func highest(_ ranks: Int, count: Int) -> Int {
        var remaining = ranks
        var packed = 0
        for _ in 0..<count {
            let top = topBit(remaining)
            packed = packed << 4 | (top + 1)
            remaining &= ~(1 << top)
        }
        return packed
    }
}
