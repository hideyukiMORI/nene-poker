import NeNePokerCore
import Testing

@testable import NeNePokerEngine

/// キャストのセリフ（FR-14・ADR 0012）。
@Suite struct BanterTests {
    @Test func everyCastMemberHasFiftyLinesCoveringEveryCue() {
        for persona in Persona.cast {
            let all = Cue.allCases.flatMap(persona.lines(for:))
            #expect(all.count == 50, "\(persona.name)")
            #expect(Set(all).count == 50, "\(persona.name) に同じセリフがある")
            for cue in Cue.allCases {
                #expect(persona.lines(for: cue).count >= 4, "\(persona.name) \(cue)")
            }
        }
    }

    /// 画面に出るので ASCII だけ・縮小版の COMMS に入る 56 文字以内。現金や入金の言葉を使わない（チップは架空の点数）。
    @Test func linesAreShortASCIIAndNeverTalkAboutMoney() {
        let forbidden = ["money", "cash", "dollar", "deposit", "casino", "bank", "$"]
        for persona in Persona.cast {
            for line in Cue.allCases.flatMap(persona.lines(for:)) {
                #expect(line.allSatisfy(\.isASCII) && line.count <= 56, "\(line)")
                #expect(!forbidden.contains { line.lowercased().contains($0) }, "\(line)")
            }
        }
    }

    @Test func theSameSeedSaysTheSameThingsAndPeopleTalk() {
        let first = Short.run(seed: 11, tables: 2).map(\.banter.lines)
        #expect(first == Short.run(seed: 11, tables: 2).map(\.banter.lines))
        #expect(first.joined().count > 10)
    }

    @Test func aNewTableOpensWithTwoRemarksAndTheChampionAlwaysSpeaks() {
        let steps = Short.run(seed: 12, tables: 2)
        let opening = steps[0].banter.lines
        #expect(opening.count == 2 && opening.allSatisfy { $0.cue == .start })
        #expect(opening.last?.seat == .south)
        for series in steps {
            guard case .tableOver(let champion) = series.phase else {
                continue
            }
            #expect(series.banter.lines.last?.seat == champion && series.banter.lines.last?.cue == .champion)
        }
    }

    @Test func remarksComeFromTheSpeakersOwnScript() {
        for series in Short.run(seed: 13, tables: 2) {
            for remark in series.banter.lines {
                #expect(remark.persona.lines(for: remark.cue).contains(remark.text))
                #expect(series.lineup.persona(at: remark.seat) == remark.persona || series.hand.number == 1)
            }
        }
    }
}
