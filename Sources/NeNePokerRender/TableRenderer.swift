/// 画面の状態と端末の大きさから、1 画面分のセルの格子を作る（ARC-011: 値を作るだけで端末を知らない）。
public enum TableRenderer {
    /// 大の配置がちょうど入る大きさ（これより小さければ 1 行の文言だけ）。
    public static let minimumSize = ScreenLayout.large.size

    /// 1 画面分の格子。
    public static func render(_ state: ScreenState, size: ScreenSize) -> Grid {
        let theme = state.options.theme
        var grid = Grid.filled(size, with: Cell(character: " ", foreground: theme.text, background: theme.ground))
        let need = minimumSize
        if size.columns >= need.columns && size.rows >= need.rows {
            ScreenLayout.large.draw(state, into: &grid)
        } else {
            let message = Wording.tooSmall(need: need)
            grid.write(message, column: 0, row: 0, colors: CellColors(foreground: theme.text, background: theme.ground))
        }
        return grid
    }
}
