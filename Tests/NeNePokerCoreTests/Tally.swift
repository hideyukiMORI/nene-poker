/// 役の種類ごとの数え上げの途中の値（テストの中だけで使う）。
struct Tally {
    var counts = [Int](repeating: 0, count: 9)
    var total = 0
    var aceHighStraightFlushes = 0
}
