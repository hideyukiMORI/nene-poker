/// 枠と棒グラフの字形の組（ADR 0009）。移植元: NeNe Igo `Sources/NeNeIgoRender/FrameStyle.swift`（コミット 2a46f6e。Igo は NeNe Reversi から移植した）。
public enum FrameStyle: Sendable, Hashable {
    /// 罫線とブロック（`┌─┤│█░▌`）。施主の選んだ形。端末がこれを 1 桁で描くときだけ使う
    case boxDrawing
    /// ASCII（`+-|#->`）。罫線が 2 桁で描かれる端末へ自動で落とす先
    case ascii
}
