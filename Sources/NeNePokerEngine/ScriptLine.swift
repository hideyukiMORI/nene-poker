/// 台本の 1 行（どの出来事で言うか・何と言うか）。移植元: NeNe Igo `Sources/NeNeIgoEngine/ScriptLine.swift`（コミット 2a46f6e）。
struct ScriptLine: Sendable, Hashable {
    let cue: Cue
    let text: String

    init(_ cue: Cue, _ text: String) {
        self.cue = cue
        self.text = text
    }
}
