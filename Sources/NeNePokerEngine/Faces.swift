/// 1 人の性格の、気分ごとの顔（ASCII 3 文字）。移植元: NeNe Igo `Sources/NeNeIgoEngine/Faces.swift`（コミット 2a46f6e）。
struct Faces: Sendable, Hashable {
    let smug: String
    let neutral: String
    let grim: String

    func face(_ mood: Mood) -> String {
        switch mood {
        case .smug:
            return smug
        case .neutral:
            return neutral
        case .grim:
            return grim
        }
    }
}
