/// 配ってからポットを分けるまでの 1 ハンド（FR-02・ADR 0007）。行動の適用と進み方は Core のこの経路だけ。
///
/// 席ごとの値は `Seat` の生の値を添字にした 4 要素の配列で持つ。値の型で、行動を適用すると新しいハンドを返す。
public struct Hand: Sendable, Hashable {
    /// このハンドの親。
    public let button: Seat
    /// スモールブラインドを出した席。
    public let smallBlindSeat: Seat
    /// ビッグブラインドを出した席。
    public let bigBlindSeat: Seat
    /// ブラインドの段階。
    public let level: BlindLevel
    /// 卓の中の 1 から始まるハンド番号。
    public let number: Int

    var holes: [[Card]]
    var deck: [Card]
    var boardCards: [Card]
    var stacks: [Int]
    var streetBets: [Int]
    var totals: [Int]
    var statuses: [SeatStatus]
    var actedAt: [Int?]
    var lastActions: [Action?]
    var currentStreet: Street
    var currentBet: Int
    var lastRaiseSize: Int
    var turn: Seat?
    var result: HandResult?

    /// 卓の席の配置と札の配る順からハンドを始める（Table だけが呼ぶ）。ブラインドを出し、手札を配り、最初の手番を決める。
    static func dealing(_ seating: Seating, stacks: [Int], order: [Card]) -> Hand {
        precondition(Set(order).count == 52 && order.count == 52, "配る順は 52 枚が 1 枚ずつ")
        var hand = Hand(seating: seating, stacks: stacks, order: order)
        hand.post(hand.level.smallBlind, from: seating.smallBlind)
        hand.post(hand.level.bigBlind, from: seating.bigBlind)
        hand.currentBet = hand.level.bigBlind
        hand.dealHoleCards()
        return hand.settled(after: seating.bigBlind)
    }

    private init(seating: Seating, stacks: [Int], order: [Card]) {
        button = seating.button
        smallBlindSeat = seating.smallBlind
        bigBlindSeat = seating.bigBlind
        level = seating.level
        number = seating.number
        holes = Array(repeating: [], count: 4)
        deck = order
        boardCards = []
        self.stacks = stacks
        streetBets = Array(repeating: 0, count: 4)
        totals = Array(repeating: 0, count: 4)
        statuses = stacks.map { $0 > 0 ? .active : .out }
        actedAt = Array(repeating: nil, count: 4)
        lastActions = Array(repeating: nil, count: 4)
        currentStreet = .preflop
        currentBet = 0
        lastRaiseSize = seating.level.bigBlind
        turn = nil
        result = nil
    }

    /// 進み具合。
    public var progress: HandProgress {
        if let result {
            return .complete(result)
        }
        if let turn {
            return .awaitingAction(turn)
        }
        guard let next = currentStreet.next else {
            preconditionFailure("リバーの賭けが終わったらハンドは終わっている")
        }
        return .awaitingDeal(next)
    }

    /// いまのストリート。
    public var street: Street {
        currentStreet
    }

    /// 開いている場札。
    public var board: [Card] {
        boardCards
    }

    /// 席の手札（配られていない席は空）。
    public func holeCards(of seat: Seat) -> [Card] {
        holes[seat.rawValue]
    }

    /// 席の手元のチップ（まだ出していない分）。
    public func stack(of seat: Seat) -> Int {
        stacks[seat.rawValue]
    }

    /// 席がこのストリートで出した額。
    public func streetBet(of seat: Seat) -> Int {
        streetBets[seat.rawValue]
    }

    /// 席がこのハンドで出した額の合計。
    public func totalBet(of seat: Seat) -> Int {
        totals[seat.rawValue]
    }

    /// 席の状態。
    public func status(of seat: Seat) -> SeatStatus {
        statuses[seat.rawValue]
    }

    /// 席がこのハンドで最後にした行動（まだなら nil）。
    public func lastAction(of seat: Seat) -> Action? {
        lastActions[seat.rawValue]
    }

    /// このストリートでいちばん高い賭けの合計。
    public var highestBet: Int {
        currentBet
    }

    /// 場に出ているチップの合計（全部のポット）。
    public var pot: Int {
        totals.reduce(0, +)
    }

    /// いまのポットの段（メインとサイド）。降りた人の分も入り、争えるのは降りていない席。
    public var potLayers: [PotLayer] {
        PotDivision.layers(stakes, button: button)
    }

    /// ポットを作るのに要る値（各席の出した額・争える席・オールインした席）。
    var stakes: PotStakes {
        let contributions = Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, totals[$0.rawValue]) })
        let contenders = Set(Seat.allCases.filter { [.active, .allIn].contains(statuses[$0.rawValue]) })
        let allIn = Set(Seat.allCases.filter { statuses[$0.rawValue] == .allIn })
        return PotStakes(contributions: contributions, contenders: contenders, allIn: allIn)
    }

    /// ブラインドを出す。足りなければ全部を出してオールインになる。
    private mutating func post(_ blind: Int, from seat: Seat) {
        let paid = min(blind, stacks[seat.rawValue])
        put(paid, from: seat)
    }

    /// チップを出す。手元が 0 になったらオールイン。
    mutating func put(_ chips: Int, from seat: Seat) {
        let index = seat.rawValue
        stacks[index] -= chips
        streetBets[index] += chips
        totals[index] += chips
        if stacks[index] == 0 {
            statuses[index] = .allIn
        }
    }

    /// 親の次の席から時計回りに 1 枚ずつ 2 周、配られる席に手札を配る。
    private mutating func dealHoleCards() {
        let seats = button.clockwiseFromNext.filter { statuses[$0.rawValue] != .out }
        for _ in 0..<2 {
            for seat in seats {
                holes[seat.rawValue].append(deck.removeFirst())
            }
        }
    }
}
