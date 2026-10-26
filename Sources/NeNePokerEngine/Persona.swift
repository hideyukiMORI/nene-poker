/// キャストの 1 名: 名前・顔・打ち方の性格（FR-06・FR-14・REQUIREMENTS の Q7・ADR 0008・0011）。セリフは後の段階で足す。
///
/// 名前は `ファイル名.拡張子` 風（兄弟の作法）で、Gambit・Reversi・Igo のキャストとは違う 4 名。最大 10 文字。
public struct Persona: Sendable, Hashable {
    /// 画面に出す名前。
    public let name: String
    /// 顔（ASCII 3 文字）。
    public let face: String
    /// 打ち方の性格。
    public let style: PlayStyle

    private init(name: String, face: String, style: PlayStyle) {
        self.name = name
        self.face = face
        self.style = style
    }

    /// 4 名。
    public static let cast: [Persona] = [bluff, nit, tilt, odds]

    /// はったりの実行ファイル。
    static let bluff = Persona(
        name: "BLUFF.EXE", face: ">:]", style: style(samples: 400, looseness: 8, aggression: 60, bluffing: 25))
    /// 強い手しか出さない古い控え（ポーカーの俗語で、手の選び方が固い人を nit と呼ぶ）。
    static let nit = Persona(
        name: "NIT.BAK", face: "-_-", style: style(samples: 800, looseness: -8, aggression: 35, bluffing: 3))
    /// 負けるとすぐ熱くなるシェル（tilt は負けて冷静さを失うこと）。
    static let tilt = Persona(
        name: "TILT.SH", face: "*o*", style: style(samples: 200, looseness: 12, aggression: 80, bluffing: 15))
    /// 確率の表。
    static let odds = Persona(
        name: "ODDS.CSV", face: "o.O", style: style(samples: 1_500, looseness: 0, aggression: 50, bluffing: 6))

    /// 名前と顔を替え、性格を決めたキャスト（`@testable import` のテストが速い設定で回すため）。
    static func make(name: String, style: PlayStyle) -> Persona {
        Persona(name: name, face: "o_o", style: style)
    }

    private static func style(samples: Int, looseness: Int, aggression: Int, bluffing: Int) -> PlayStyle {
        guard
            let style = PlayStyle.make(
                samples: samples, looseness: looseness, aggression: aggression, bluffing: bluffing)
        else {
            preconditionFailure("キャストの性格が範囲外")
        }
        return style
    }

    /// 拡張子の前の名前（LOG と STACKS に出す短い名前）。
    public var shortName: String {
        String(name.split(separator: ".").first ?? Substring(name))
    }
}
