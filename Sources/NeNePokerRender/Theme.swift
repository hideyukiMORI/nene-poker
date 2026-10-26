import NeNePokerCore

/// カラーテーマ。色の値を持つのはここだけ（FR-12・ADR 0008）。
///
/// 名前と地・パネル・枠・文字・控えめな文字・強調 2 色は NeNe Igo の NEON（`Sources/NeNeIgoRender/Theme.swift`・コミット 2a46f6e）を写した。
/// ポーカー用に、卓の地・卓の上の文字・表の札の地・スート 4 色・札の裏と裏の文字・降りた札の地と文字・手番の印・チップの棒の色を足した（画面仕様の Design Tokens）。
/// コントラストの条件はテストで計算する。12 テーマは Phase 3-6 で足す。
public struct Theme: Sendable, Hashable {
    /// 画面と起動オプションに使う名前（`--theme NEON`）。
    public let name: String
    let ground: Rgb
    let panel: Rgb
    let frame: Rgb
    let text: Rgb
    let dim: Rgb
    let accent: Rgb
    let accentAlt: Rgb
    let felt: Rgb
    let feltText: Rgb
    let cardFace: Rgb
    let suitSpade: Rgb
    let suitHeart: Rgb
    let suitDiamond: Rgb
    let suitClub: Rgb
    let cardBack: Rgb
    let cardBackText: Rgb
    let foldedFace: Rgb
    let foldedText: Rgb
    let turnMarker: Rgb
    let chipBar: Rgb

    /// テーマの一覧。最初が既定。
    public static let catalog: [Theme] = [
        Theme(
            name: "NEON",
            hex: [
                0x05070D, 0x0A1020, 0x1E4D6B, 0xC8D3E0, 0x6B7F99, 0x00E5FF, 0xFF2E97,
                0x0A2E2A, 0xD8F3EC, 0xEAF2F8, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xD9478C, 0x1A0410, 0x3E4A55, 0xD5DCE3, 0x00E5FF, 0x00E5FF,
            ])
    ]

    /// 既定のテーマ。
    public static let standard = catalog[0]

    /// 名前のテーマ（大文字小文字を区別しない）。無ければ nil。
    public static func named(_ name: String) -> Theme? {
        catalog.first { $0.name == name.uppercased() }
    }

    /// 地・パネル・枠・文字・控えめ・強調 2 色・卓の地・卓の文字・札の地・スート 4 色・裏・裏の文字・降りた札の地と文字・手番・棒の 20 色から作る。
    private init(name: String, hex: [UInt32]) {
        precondition(hex.count == 20, "テーマの色は 20 個")
        let rgb = hex.map { Rgb(red: UInt8($0 >> 16 & 0xFF), green: UInt8($0 >> 8 & 0xFF), blue: UInt8($0 & 0xFF)) }
        self.name = name
        (ground, panel, frame, text, dim, accent, accentAlt) = (rgb[0], rgb[1], rgb[2], rgb[3], rgb[4], rgb[5], rgb[6])
        (felt, feltText, cardFace) = (rgb[7], rgb[8], rgb[9])
        (suitSpade, suitHeart, suitDiamond, suitClub) = (rgb[10], rgb[11], rgb[12], rgb[13])
        (cardBack, cardBackText, foldedFace, foldedText) = (rgb[14], rgb[15], rgb[16], rgb[17])
        (turnMarker, chipBar) = (rgb[18], rgb[19])
    }

    /// スートの文字色（4 色のデッキ: スペードは黒系・ハートは赤系・ダイヤは青系・クラブは緑系）。
    func color(of suit: Suit) -> Rgb {
        switch suit {
        case .spades:
            return suitSpade
        case .hearts:
            return suitHeart
        case .diamonds:
            return suitDiamond
        case .clubs:
            return suitClub
        }
    }
}
