/// 札の集まり（同じ札は 1 度しか入らない）。役判定と勝率の見積もりが使う（ADR 0005）。
///
/// 64 ビットの整数で持つ。スートごとに 16 ビットの区画を取り、その下位 13 ビットがランク（2 が最下位）。
public struct CardSet: Sendable, Hashable {
    /// スートごとの区画のビット。
    let bits: UInt64

    private init(bits: UInt64) {
        self.bits = bits
    }

    /// 空の集まり。
    public static let empty = CardSet(bits: 0)

    /// 札の並びから作る（重なった札は 1 枚として入る）。
    public static func of(_ cards: [Card]) -> CardSet {
        cards.reduce(empty) { $0.inserting($1) }
    }

    /// 札を 1 枚足した集まり。
    public func inserting(_ card: Card) -> CardSet {
        CardSet(bits: bits | (1 << UInt64(card.bitIndex)))
    }

    /// 2 つの集まりを合わせた集まり。
    public func union(_ other: CardSet) -> CardSet {
        CardSet(bits: bits | other.bits)
    }

    /// 札が入っているか。
    public func contains(_ card: Card) -> Bool {
        bits & (1 << UInt64(card.bitIndex)) != 0
    }

    /// 入っている札の数。
    public var count: Int {
        bits.nonzeroBitCount
    }

    /// 入っている札（スートの順・ランクの弱い順）。
    public var cards: [Card] {
        Suit.allCases.flatMap { suit in
            Rank.allCases.map { Card(rank: $0, suit: suit) }.filter(contains)
        }
    }

    /// スートの区画の 13 ビット（ランクの集まり）。
    func ranks(of suit: Suit) -> Int {
        Int((bits >> UInt64(suit.rawValue * 16)) & 0x1FFF)
    }
}
