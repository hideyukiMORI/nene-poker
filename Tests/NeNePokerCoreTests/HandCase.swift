import NeNePokerCore
import Testing

/// 手で作った札の組と、その役の種類と比べる順のランク（テストの中だけで使う）。
struct HandCase: Sendable, CustomTestStringConvertible {
    let cards: String
    let category: HandCategory
    let ranks: [Rank]

    var testDescription: String {
        cards
    }

    /// 7 枚の手で作った例。最良の 5 枚がどれかを、役の種類と比べるランクで書く。
    static let sevenCardExamples: [HandCase] = [
        HandCase(cards: "As Ks Qs Js Ts 9s 8s", category: .straightFlush, ranks: [.ace]),
        HandCase(cards: "5h 4h 3h 2h Ah Kh Kd", category: .straightFlush, ranks: [.five]),
        HandCase(cards: "9c 9d 9h 9s Ac Kd 2h", category: .fourOfAKind, ranks: [.nine, .ace]),
        HandCase(cards: "9c 9d 9h 9s 8c 8d 8h", category: .fourOfAKind, ranks: [.nine, .eight]),
        HandCase(cards: "Kc Kd Kh 3s 3c 3d 2h", category: .fullHouse, ranks: [.king, .three]),
        HandCase(cards: "Kc Kd Kh 3s 3c Qd Qh", category: .fullHouse, ranks: [.king, .queen]),
        HandCase(cards: "Ad 9d 7d 4d 2d Kd Qs", category: .flush, ranks: [.ace, .king, .nine, .seven, .four]),
        HandCase(cards: "Ad 9d 7d 4d 2d Ac As", category: .flush, ranks: [.ace, .nine, .seven, .four, .two]),
        HandCase(cards: "Ah 2c 3d 4s 5h Kc Kd", category: .straight, ranks: [.five]),
        HandCase(cards: "Ah 2c 3d 4s 5h 6c Kd", category: .straight, ranks: [.six]),
        HandCase(cards: "Ts Jd Qc Kh As 9c 2d", category: .straight, ranks: [.ace]),
        HandCase(cards: "Qs Ks Ah 2c 3d 8h 9d", category: .highCard, ranks: [.ace, .king, .queen, .nine, .eight]),
        HandCase(cards: "7s 7d 7c Ah Js 4d 2c", category: .threeOfAKind, ranks: [.seven, .ace, .jack]),
        HandCase(cards: "8s 8d 5c 5h 3s 3d Kc", category: .twoPair, ranks: [.eight, .five, .king]),
        HandCase(cards: "8s 8d 5c 5h 3s 3d 2c", category: .twoPair, ranks: [.eight, .five, .three]),
        HandCase(cards: "Qs Qd 9c 7h 5s 3d 2c", category: .onePair, ranks: [.queen, .nine, .seven, .five]),
        HandCase(cards: "Ks Jd 9c 7h 5s 3d 2c", category: .highCard, ranks: [.king, .jack, .nine, .seven, .five]),
    ]
}
