import NeNePokerCore

/// カラーテーマ。色の値を持つのはここだけ（FR-12・ADR 0008）。
///
/// 名前と順と、地・パネル・枠・文字・控えめな文字・強調 2 色は NeNe Igo の 12 テーマ（`Sources/NeNeIgoRender/Theme.swift`・コミット 2a46f6e）を写した。
/// ポーカー用に、卓の地・卓の上の文字・表の札の地・スート 4 色・札の裏と裏の文字・降りた札の地と文字・手番の印・チップの棒の色を足した（画面仕様の Design Tokens・ADR 0012）。
/// 暗いテーマの卓の地は、地の色を緑へ寄せて強調の色を少し混ぜた色。PAPER だけは明るい地の上に暗い緑の卓を置く。スートの 4 色は全テーマ共通で、札の地は明るい色。
/// コントラストの条件はテストで計算する。
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

    /// 12 のテーマ（`t` で巡る順）。最初が既定。
    public static let catalog: [Theme] = [
        Theme(
            name: "NEON",
            hex: [
                0x05070D, 0x0A1020, 0x1E4D6B, 0xC8D3E0, 0x6B7F99, 0x00E5FF, 0xFF2E97,
                0x0C3733, 0xDEE5EC, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xFF2E97, 0x10060C, 0x355659, 0xE6EAF0, 0x00E5FF, 0x00E5FF,
            ]),
        Theme(
            name: "PHOSPHOR",
            hex: [
                0x020803, 0x061208, 0x1C4D24, 0x9CF5A8, 0x4F9A5B, 0x39FF6A, 0xD8FF3E,
                0x0E3924, 0xC4F9CB, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xD8FF3E, 0x10060C, 0x36574F, 0xE6EAF0, 0x39FF6A, 0x39FF6A,
            ]),
        Theme(
            name: "AMBER",
            hex: [
                0x0A0602, 0x140C04, 0x5A3A12, 0xFFC879, 0xA87A3C, 0xFFB000, 0xFF6A1A,
                0x1F331C, 0xFFDEAF, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xFF6A1A, 0x10060C, 0x41544A, 0xE6EAF0, 0xFFB000, 0xFFB000,
            ]),
        Theme(
            name: "SYNTHWAVE",
            hex: [
                0x0D0221, 0x160534, 0x4B1D7A, 0xE7D7FF, 0x9A84C4, 0xFF3CAC, 0x00F0FF,
                0x21293A, 0xF1E7FF, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0x00F0FF, 0x10060C, 0x424D5E, 0xE6EAF0, 0xFF3CAC, 0xFF3CAC,
            ]),
        Theme(
            name: "GLACIER",
            hex: [
                0x03080F, 0x08121E, 0x2A4A6A, 0xDCEBFA, 0x7E98B3, 0x7FD4FF, 0xB6A0FF,
                0x133634, 0xEAF3FC, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xB6A0FF, 0x10060C, 0x39565A, 0xE6EAF0, 0x7FD4FF, 0x7FD4FF,
            ]),
        Theme(
            name: "BLOODMOON",
            hex: [
                0x080203, 0x130507, 0x5A1620, 0xF2D0D4, 0xA06A72, 0xFF2B3F, 0xFFB347,
                0x1D2821, 0xF7E3E5, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xFFB347, 0x10060C, 0x404C4D, 0xE6EAF0, 0xF7E3E5, 0xFF2B3F,
            ]),
        Theme(
            name: "VAPOR",
            hex: [
                0x120B1F, 0x1C1230, 0x5A3F7F, 0xF3E8FF, 0xA897C4, 0x7DF9FF, 0xFF9DE2,
                0x1C3B3E, 0xF8F1FF, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xFF9DE2, 0x10060C, 0x3F5960, 0xE6EAF0, 0x7DF9FF, 0x7DF9FF,
            ]),
        Theme(
            name: "MONO",
            hex: [
                0x050505, 0x101010, 0x3A3A3A, 0xD9D9D9, 0x8A8A8A, 0xFFFFFF, 0xBDBDBD,
                0x2C2C2C, 0xE8E8E8, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xBDBDBD, 0x10060C, 0x494F55, 0xE6EAF0, 0xFFFFFF, 0xFFFFFF,
            ]),
        Theme(
            name: "TOXIC",
            hex: [
                0x06040A, 0x0F0A16, 0x3E2A5A, 0xE2F5C8, 0x8E9A78, 0xB6FF00, 0xC266FF,
                0x183722, 0xEEF9DE, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xC266FF, 0x10060C, 0x3C564E, 0xE6EAF0, 0xB6FF00, 0xB6FF00,
            ]),
        Theme(
            name: "GILDED",
            hex: [
                0x070605, 0x11100C, 0x4A3F22, 0xEDE3C8, 0x9C9278, 0xE8C15A, 0x5AD1C8,
                0x1C3423, 0xF4EEDE, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0x5AD1C8, 0x10060C, 0x3F544F, 0xE6EAF0, 0xE8C15A, 0xE8C15A,
            ]),
        Theme(
            name: "ABYSS",
            hex: [
                0x01060A, 0x041018, 0x123A4F, 0xCBE7F2, 0x6E93A3, 0x00C2A8, 0x3D8BFF,
                0x0A342C, 0xE0F1F7, 0xEEF2F6, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0x3D8BFF, 0x10060C, 0x335455, 0xE6EAF0, 0x00C2A8, 0x00C2A8,
            ]),
        Theme(
            name: "PAPER",
            hex: [
                0xF4F1EA, 0xE6E1D6, 0xB8AE9A, 0x2A2622, 0x5E564C, 0x0060C7, 0xA81D33,
                0x2F6B4F, 0xFFFFFF, 0xFFFFFF, 0x111827, 0xC8102E, 0x1D4ED8, 0x14713A,
                0xF2C14E, 0x2A2622, 0x5D6B66, 0xFFFFFF, 0xFFFFFF, 0x0060C7,
            ]),
    ]

    /// 既定のテーマ。
    public static let standard = catalog[0]

    /// `t` を押したときの次のテーマ（最後の次は最初）。
    public var next: Theme {
        let index = Self.catalog.firstIndex(of: self) ?? 0
        return Self.catalog[(index + 1) % Self.catalog.count]
    }

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
