/// 端末の文字セル 1 つ。1 つの `Character` が 1 桁を占めると前提する（画面の文字は ASCII と枠の字形だけ・ADR 0008）。
///
/// 移植元: NeNe Igo `Sources/NeNeIgoRender/Cell.swift`（コミット 2a46f6e）。石の下線（Igo の ADR 0009）は要らないので落とした。
public struct Cell: Sendable, Hashable {
    public let character: Character
    public let foreground: Rgb
    public let background: Rgb
}
