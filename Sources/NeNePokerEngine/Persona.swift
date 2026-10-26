/// キャストの 1 名: 名前・打ち方の性格・顔・セリフ（FR-06・FR-14・REQUIREMENTS の Q7・ADR 0008・0011・0012）。
///
/// 名前は `ファイル名.拡張子` 風（兄弟の作法）で、Gambit・Reversi・Igo のキャストとは違う 4 名。最大 10 文字。セリフは 1 人 50 本（英語）。
public struct Persona: Sendable, Hashable {
    /// 画面に出す名前。
    public let name: String
    /// 打ち方の性格。
    public let style: PlayStyle
    private let faces: Faces
    private let script: [ScriptLine]

    private init(name: String, style: PlayStyle, faces: Faces, script: [ScriptLine]) {
        self.name = name
        self.style = style
        self.faces = faces
        self.script = script
    }

    /// 4 名。
    public static let cast: [Persona] = [bluff, nit, tilt, odds]

    /// はったりの実行ファイル。
    static let bluff = Persona(
        name: "BLUFF.EXE", style: style(samples: 400, looseness: 8, aggression: 60, bluffing: 25),
        faces: Faces(smug: ">:]", neutral: ">:|", grim: ">:["), script: bluffScript)
    /// 強い手しか出さない古い控え（ポーカーの俗語で、手の選び方が固い人を nit と呼ぶ）。
    static let nit = Persona(
        name: "NIT.BAK", style: style(samples: 800, looseness: -8, aggression: 35, bluffing: 3),
        faces: Faces(smug: "-.-", neutral: "-_-", grim: "x_x"), script: nitScript)
    /// 負けるとすぐ熱くなるシェル（tilt は負けて冷静さを失うこと）。
    static let tilt = Persona(
        name: "TILT.SH", style: style(samples: 200, looseness: 12, aggression: 80, bluffing: 15),
        faces: Faces(smug: "^o^", neutral: "*o*", grim: "#o#"), script: tiltScript)
    /// 確率の表。
    static let odds = Persona(
        name: "ODDS.CSV", style: style(samples: 1_500, looseness: 0, aggression: 50, bluffing: 6),
        faces: Faces(smug: "o.o", neutral: "o.O", grim: "O.O"), script: oddsScript)

    /// 気分ごとの顔（ASCII 3 文字）。
    public func face(_ mood: Mood) -> String {
        faces.face(mood)
    }

    /// その出来事のセリフ。
    public func lines(for cue: Cue) -> [String] {
        script.filter { $0.cue == cue }.map(\.text)
    }

    /// 名前と性格を決めたキャスト（顔とセリフは ODDS.CSV のもの）（`@testable import` のテストが速い設定で回すため）。
    static func make(name: String, style: PlayStyle) -> Persona {
        Persona(name: name, style: style, faces: Faces(smug: "o_o", neutral: "o_o", grim: "o_o"), script: oddsScript)
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
