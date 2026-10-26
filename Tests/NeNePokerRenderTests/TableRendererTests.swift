import NeNePokerCore
import NeNePokerEngine
import Testing

@testable import NeNePokerRender

/// 卓の画面（画面仕様の B 案の大の配置・FR-07・FR-07a・FR-07b・FR-10・FR-15・ADR 0008）。
@Suite struct TableRendererTests {
    @Test func theTwoLayoutsAre112By28And80By24AndASmallerTerminalGetsOneLine() {
        #expect(TableRenderer.largeSize == ScreenSize(columns: 112, rows: 28))
        #expect(TableRenderer.minimumSize == ScreenSize(columns: 80, rows: 24))
        let options = DisplayOptions(theme: .standard, view: .you, traits: Steps.boxed)
        let state = ScreenState(series: Steps.all[0], options: options, seed: 1, countdown: nil)
        let small = TableRenderer.render(state, size: ScreenSize(columns: 79, rows: 24))
        #expect(Steps.text(small).hasPrefix("TERMINAL TOO SMALL (NEED 80x24)"))
        #expect(Steps.text(TableRenderer.render(state, size: ScreenSize(columns: 100, rows: 26))).contains("[ MATCH ]"))
        #expect(TableRenderer.render(state, size: ScreenSize(columns: 0, rows: 0)).size.columns == 0)
    }

    @Test func theCompactLayoutKeepsEverythingAndWrapsLongHandNames() {
        let compact = Steps.text(
            Steps.render(Steps.all[5], view: .you, layout: Layout(theme: .standard, compact: true)))
        #expect(compact.contains("[ MATCH ]") && compact.contains("[ STACKS ]") && compact.contains("[ LOG ]"))
        #expect(compact.contains("[q]") && compact.contains("[t]") && compact.contains("[v] YOU"))
        #expect(HandName.wrapped("FULL HOUSE, KINGS OVER THREES", width: 25) == ["FULL HOUSE,", "KINGS OVER THREES"])
        #expect(HandName.wrapped("PAIR OF QUEENS", width: 25) == ["PAIR OF QUEENS"])
    }

    @Test func commsShowTheLatestTwoRemarksWithTheSpeakerAndFace() throws {
        let series = Steps.all[0]
        let text = Steps.text(Steps.render(series, view: .you))
        for remark in series.banter.lines {
            #expect(text.contains(remark.persona.name) && text.contains(remark.text))
        }
        #expect(series.banter.lines.count == 2)
    }

    @Test func themesCycleThroughTwelveAndCanBeNamed() {
        #expect(Theme.catalog.count == 12)
        #expect(
            Theme.catalog.map(\.name) == [
                "NEON", "PHOSPHOR", "AMBER", "SYNTHWAVE", "GLACIER", "BLOODMOON", "VAPOR", "MONO", "TOXIC", "GILDED",
                "ABYSS", "PAPER",
            ])
        var theme = Theme.standard
        for _ in 0..<12 {
            theme = theme.next
        }
        #expect(theme == .standard)
        #expect(Theme.named("paper")?.name == "PAPER" && Theme.named("nope") == nil)
        let options = DisplayOptions(theme: .standard, view: .you, traits: Steps.boxed)
        #expect(options.cyclingTheme.theme.name == "PHOSPHOR" && options.cyclingTheme.view == .you)
    }

    /// ASCII の枠では画面の文字はすべて ASCII。罫線の枠でも、ASCII 以外は枠の字形だけ。
    /// スート記号（Emoji=Yes で前景色が効かない）と `▶`（Ambiguous・Emoji の異体字あり）は画面に出ない（FR-07b）。
    @Test func charactersAreASCIIOrFrameGlyphsAndNeverSuitSymbols() {
        let glyphs = FrameGlyphs.of(.boxDrawing)
        let allowed = Set(
            [
                glyphs.topLeft, glyphs.topRight, glyphs.teeLeft, glyphs.teeRight, glyphs.bottomLeft, glyphs.bottomRight,
                glyphs.horizontal, glyphs.vertical, glyphs.barFull, glyphs.barEmpty, glyphs.barOpen, glyphs.barClose,
                glyphs.marker, glyphs.cursor, glyphs.turn,
            ].flatMap { Array($0) })
        let forbidden = Set("\u{2660}\u{2665}\u{2666}\u{2663}\u{2664}\u{2661}\u{2662}\u{2667}\u{25B6}")
        for series in Steps.sampled {
            for view in ViewMode.allCases {
                let ascii = Steps.cells(Steps.render(series, view: view, frame: .ascii))
                #expect(ascii.allSatisfy { $0.character.isASCII })
                let boxed = Steps.cells(Steps.render(series, view: view))
                #expect(boxed.allSatisfy { $0.character.isASCII || allowed.contains($0.character) })
                #expect(!boxed.contains { forbidden.contains($0.character) })
            }
        }
    }

    /// 12 テーマ × 2 つの配置 × 2 つの VIEW で、文字のあるセル（英字・数字・卓の上の `#`・`-` 等）の前景と背景は 4.5:1 以上（WCAG・画面仕様の Accessibility Notes）。
    /// 枠の罫線と飾りは控えめな色で描く設計なので対象にしない。
    @Test(arguments: Layout.all)
    func textCellsHaveEnoughContrast(_ layout: Layout) {
        let marks = Set("#-+/,()")
        for series in Steps.sampled {
            for view in ViewMode.allCases {
                for cell in Steps.cells(Steps.render(series, view: view, layout: layout))
                where cell.character.isLetter || cell.character.isNumber
                    || (marks.contains(cell.character) && cell.background != layout.theme.ground
                        && cell.background != layout.theme.panel)
                {
                    #expect(Contrast.ratio(cell.foreground, cell.background) >= 4.5, "\(layout) \(cell)")
                }
            }
        }
    }

    /// 画面仕様の Design Tokens の条件（12 テーマすべて）。
    @Test(arguments: Theme.catalog)
    func theThemeTokensMeetTheirContrastConditions(_ theme: Theme) {
        #expect(theme.felt != theme.ground)
        #expect(Contrast.ratio(theme.feltText, theme.felt) >= 4.5)
        #expect(Contrast.ratio(theme.cardFace, theme.felt) >= 3)
        #expect(Contrast.ratio(theme.cardBack, theme.felt) >= 3)
        #expect(Contrast.ratio(theme.cardBackText, theme.cardBack) >= 4.5)
        #expect(Contrast.ratio(theme.foldedText, theme.foldedFace) >= 4.5)
        #expect(Contrast.ratio(theme.turnMarker, theme.felt) >= 4.5)
        #expect(Contrast.ratio(theme.chipBar, theme.panel) >= 3)
        #expect(Contrast.ratio(theme.chipBar, theme.ground) >= 3)
        let suits = Suit.allCases.map(theme.color(of:))
        #expect(Set(suits).count == 4)
        for suit in suits {
            #expect(Contrast.ratio(suit, theme.cardFace) >= 4.5)
        }
    }

    @Test func theKeyBarAlwaysShowsQuitAndTheViewAndToggles() {
        let you = Steps.text(Steps.render(Steps.all[3], view: .you))
        let all = Steps.text(Steps.render(Steps.all[3], view: .all))
        #expect(you.contains("[q] QUIT") && you.contains("[v] VIEW: YOU"))
        #expect(all.contains("[v] VIEW: ALL"))
        #expect(you.contains("NENE//POKER") && you.contains("TABLE 001") && you.contains("[ MATCH ]"))
        #expect(you.contains("[ STACKS ]") && you.contains("[ LOG ]"))
    }

    /// ハンドが終わったら、卓の席の下のチップも分配の後の値（ADR 0010。実機の写真で、勝った人が `39` のまま STACKS は `4,097` だった）。
    @Test func seatStacksOnTheFeltShowTheChipsAfterTheAward() throws {
        let over = try #require(
            Steps.all.first { series in
                guard case .complete(let result) = series.hand.progress else {
                    return false
                }
                return result.stacks[.north, default: 0] != series.hand.stack(of: .north)
            })
        guard case .complete(let result) = over.hand.progress else {
            return
        }
        let text = Steps.text(Steps.render(over, view: .you))
        let northRows = text.split(separator: "\n").dropFirst(3).prefix(4).joined(separator: "\n")
        #expect(northRows.contains(Wording.chips(result.stacks[.north, default: 0])))
    }

    @Test func aFinishedTableShowsTheChampionAndTheCountdown() throws {
        let over = try #require(Steps.all.first { if case .tableOver = $0.phase { true } else { false } })
        let text = Steps.text(Steps.render(over, view: .you))
        #expect(
            text.contains("[ RESULT ]") && text.contains("CHAMPION") && text.contains("NEXT TABLE")
                && text.contains("2s"))
    }
}
