/// 枠の字形（`FrameStyle` ごと）。移植元: NeNe Igo `Sources/NeNeIgoRender/FrameGlyphs.swift`（コミット 2a46f6e。Igo は NeNe Reversi から移植した）。
struct FrameGlyphs: Sendable, Hashable {
    let topLeft: String
    let topRight: String
    let teeLeft: String
    let teeRight: String
    let bottomLeft: String
    let bottomRight: String
    let horizontal: String
    let vertical: String
    let barFull: String
    let barEmpty: String
    let barOpen: String
    let barClose: String
    /// 行頭の印（COMMS の話し手・HUD の題）。
    let marker: String
    /// LOG の手番のカーソル。
    let cursor: String
    /// 卓の手番の印。`▶` は Ambiguous で Emoji の異体字もあるので、どちらの枠でも ASCII の `>`（画面仕様・ADR 0008）。
    let turn: String

    static func of(_ style: FrameStyle) -> FrameGlyphs {
        switch style {
        case .boxDrawing:
            return FrameGlyphs(
                topLeft: "┌", topRight: "┐", teeLeft: "├", teeRight: "┤", bottomLeft: "└", bottomRight: "┘",
                horizontal: "─", vertical: "│", barFull: "█", barEmpty: "░", barOpen: "▕", barClose: "▏", marker: "▌",
                cursor: "▌", turn: ">")
        case .ascii:
            return FrameGlyphs(
                topLeft: "+", topRight: "+", teeLeft: "+", teeRight: "+", bottomLeft: "+", bottomRight: "+",
                horizontal: "-", vertical: "|", barFull: "#", barEmpty: "-", barOpen: "[", barClose: "]", marker: ">",
                cursor: "_", turn: ">")
        }
    }
}
