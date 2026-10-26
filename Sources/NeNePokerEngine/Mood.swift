/// 発言のときの気分。移植元: NeNe Igo `Sources/NeNeIgoEngine/Mood.swift`（コミット 2a46f6e）。
public enum Mood: Sendable, Hashable, CaseIterable {
    /// 得意げ（賭けた・取った・勝った）。
    case smug
    /// ふつう（始まり・降りた・オールイン・静かな卓）。
    case neutral
    /// 沈んでいる（負けた・飛んだ）。
    case grim
}
