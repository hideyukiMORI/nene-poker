import NeNePokerCore

/// 誰が、どの出来事について話すか（確率は百分率）。
struct Prompt: Sendable, Hashable {
    let seat: Seat
    let cue: Cue
    let chance: Int
}
