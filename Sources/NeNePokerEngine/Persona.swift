/// キャストの 1 名: 名前と顔（FR-14・REQUIREMENTS の Q7・ADR 0008）。行動の性格とセリフは後の段階で足す。
///
/// 名前は `ファイル名.拡張子` 風（兄弟の作法）で、Gambit・Reversi・Igo のキャストとは違う 4 名。最大 10 文字。
public struct Persona: Sendable, Hashable {
    /// 画面に出す名前。
    public let name: String
    /// 顔（ASCII 3 文字）。
    public let face: String

    private init(name: String, face: String) {
        self.name = name
        self.face = face
    }

    /// 4 名。
    public static let cast: [Persona] = [bluff, nit, tilt, odds]

    /// はったりの実行ファイル。
    static let bluff = Persona(name: "BLUFF.EXE", face: ">:]")
    /// 強い手しか出さない古い控え（ポーカーの俗語で、手の選び方が固い人を nit と呼ぶ）。
    static let nit = Persona(name: "NIT.BAK", face: "-_-")
    /// 負けるとすぐ熱くなるシェル（tilt は負けて冷静さを失うこと）。
    static let tilt = Persona(name: "TILT.SH", face: "*o*")
    /// 確率の表。
    static let odds = Persona(name: "ODDS.CSV", face: "o.O")

    /// 拡張子の前の名前（LOG と STACKS に出す短い名前）。
    public var shortName: String {
        String(name.split(separator: ".").first ?? Substring(name))
    }
}
