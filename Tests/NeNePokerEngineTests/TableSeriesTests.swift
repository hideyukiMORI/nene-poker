import NeNePokerCore
import Testing

@testable import NeNePokerEngine

/// 卓の列（FR-01・FR-04・FR-05・FR-07・ADR 0008）。
@Suite struct TableSeriesTests {
    @Test func everyTableEndsWithOneChampionHoldingEveryChipAndTheNextTableStartsFresh() {
        let steps = Short.run(seed: 1, tables: 5)
        #expect(steps.last?.tally.finishedTables == 5)
        let overs = steps.filter { if case .tableOver = $0.phase { true } else { false } }
        #expect(overs.count == 5)
        for over in overs {
            guard case .tableOver(let champion) = over.phase else {
                continue
            }
            #expect(over.table.stack(of: champion) == 800)
            #expect(over.table.liveSeats == [champion])
        }
        let starts = steps.filter { $0.hand.number == 1 && $0.events.isEmpty && $0.phase == .playing }
        #expect(starts.map(\.tableNumber) == [1, 2, 3, 4, 5])
        for start in starts {
            #expect(Seat.allCases.allSatisfy { start.table.stack(of: $0) == 200 })
        }
    }

    @Test func chipsAreConservedAtEveryStep() {
        for series in Short.run(seed: 2, tables: 3) {
            let hand = series.hand
            let chips = Seat.allCases.reduce(0) { $0 + hand.stack(of: $1) } + hand.pot
            #expect(chips == 800)
        }
    }

    @Test func theSameSeedPlaysTheSameTablesAndADifferentSeedDoesNot() {
        let first = Short.run(seed: 3, tables: 2).map(\.events)
        #expect(first == Short.run(seed: 3, tables: 2).map(\.events))
        #expect(first != Short.run(seed: 4, tables: 2).map(\.events))
    }

    @Test func theMainPlayerSitsSouthAndTheLineupIsTheFourCastMembers() {
        for seed in 0..<20 {
            var generator = SplitMix64(seed: UInt64(seed))
            let series = TableSeries.first(using: &generator)
            #expect(series.lineup.main == series.lineup.persona(at: .south))
            #expect(Set(Seat.allCases.map { series.lineup.persona(at: $0).name }) == Set(Persona.cast.map(\.name)))
        }
    }

    @Test func theCastHasFourNewNamesInTheFileNameStyle() {
        let siblings = [
            "VEX.EXE", "MORT.SH", "NULL_PTR", "GRANNY.DLL", "FLIP.BAT", "CORNER.SYS", "SPAM.EML", "LAZY.CRON",
            "SENTE.SYS",
            "TENUKI.LOG", "MOYO.PNG", "SEKI.LCK",
        ]
        #expect(Persona.cast.count == 4)
        for persona in Persona.cast {
            #expect(!siblings.contains(persona.name))
            #expect(persona.name.count <= 10)
            #expect(persona.name.contains("."))
            for mood in Mood.allCases {
                #expect(persona.face(mood).count == 3 && persona.face(mood).allSatisfy(\.isASCII))
            }
        }
    }

    /// AI が返す行動は必ず合法（指示書 第 2-2 節）。4 名の性格それぞれで、乱数で進めた卓のどの手番でも確かめる。
    @Test func everyCastMemberOnlyChoosesLegalActions() {
        var generator = SplitMix64(seed: 5)
        for series in Short.run(seed: 5, tables: 2) {
            guard let legal = series.hand.legalActions else {
                continue
            }
            for persona in Persona.cast {
                let fast = Persona.make(name: persona.name, style: TableSeriesTests.quick(persona.style))
                let action = ActionChooser.choose(in: series.hand, style: fast.style, using: &generator)
                #expect(legal.rejection(of: action) == nil, "\(persona.name) \(action)")
            }
        }
    }

    /// 性格はそのまま、見積もりの回数だけ減らす（テストを速くするため）。
    private static func quick(_ style: PlayStyle) -> PlayStyle {
        PlayStyle.make(samples: 20, looseness: style.looseness, aggression: style.aggression, bluffing: style.bluffing)
            ?? style
    }
}
