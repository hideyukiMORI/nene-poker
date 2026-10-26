import NeNePokerCore

/// 卓の発言（COMMS）の状態。どの出来事で誰が話すかの規則はここだけにある（FR-14・ADR 0012）。
///
/// - 1 歩に 1 行まで。その歩でいちばん優先度の高い出来事だけを見て、確率に外れたら黙る
/// - 同じ席は話してから 3 歩は黙る（卓の始まりと終わりは例外）
/// - 同じ人は直近 8 回と同じセリフを言わない。乱数は引数から受け取るので、同じシードからは同じ会話になる
/// - 札の見せ方（VIEW）は知らない。ブラフの手札を明かす言い方はしない（セリフは本人の気分だけを言う）
/// 移植元: NeNe Igo `Sources/NeNeIgoEngine/Banter.swift`（コミット 2a46f6e）の形。出来事をポーカーのものに替えた。
public struct Banter: Sendable, Hashable {
    /// 画面に出す発言（古い順・最後の 2 つ）。
    public let lines: [Remark]
    private let recent: [String: [String]]
    private let lastSpoke: [Seat: Int]
    private let step: Int

    static let silent = Banter(lines: [], recent: [:], lastSpoke: [:], step: 0)

    /// 1 歩進めた後の発言。`prompts` は優先度の高い順の候補で、最初に話せる席の 1 つだけを抽選する。
    func after(_ prompts: [Prompt], lineup: Lineup, using generator: inout some RandomNumberGenerator) -> Banter {
        let ticked = Banter(lines: lines, recent: recent, lastSpoke: lastSpoke, step: step + 1)
        guard let prompt = prompts.first(where: { $0.chance >= 100 || ticked.mayTalk($0.seat) }) else {
            return ticked
        }
        guard Int.random(in: 0..<100, using: &generator) < prompt.chance else {
            return ticked
        }
        return ticked.saying(prompt, lineup: lineup, using: &generator)
    }

    private func mayTalk(_ seat: Seat) -> Bool {
        lastSpoke[seat].map { step - $0 > 3 } ?? true
    }

    /// しばらく誰も話していないか（12 歩）。
    func isQuiet() -> Bool {
        step - (lastSpoke.values.max() ?? 0) >= 12
    }

    /// 1 行を言う。直近 8 回のセリフを避けて乱数で選ぶ（全部が直近なら避けない）。
    func saying(_ prompt: Prompt, lineup: Lineup, using generator: inout some RandomNumberGenerator) -> Banter {
        let persona = lineup.persona(at: prompt.seat)
        let all = persona.lines(for: prompt.cue)
        let said = recent[persona.name] ?? []
        let fresh = all.filter { !said.contains($0) }
        let text = (fresh.isEmpty ? all : fresh).randomElement(using: &generator) ?? ""
        var remembered = recent
        remembered[persona.name] = Array((said + [text]).suffix(8))
        var spoke = lastSpoke
        spoke[prompt.seat] = step
        let remark = Remark(seat: prompt.seat, persona: persona, cue: prompt.cue, text: text)
        return Banter(lines: Array((lines + [remark]).suffix(2)), recent: remembered, lastSpoke: spoke, step: step)
    }
}
