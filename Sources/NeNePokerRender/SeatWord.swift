import NeNePokerCore
import NeNePokerEngine

/// 席の下に出す直前の行動の 1 語（画面仕様の Seat）。降りた・オールインはハンドの終わりまで、それ以外はそのストリートの間だけ出す。
enum SeatWord {
    static func of(_ seat: Seat, events: [TableEvent]) -> String? {
        var word: String?
        var sticky = false
        for event in events {
            switch event {
            case .dealt:
                word = sticky ? word : nil
            case .acted(let mover, let action, let total) where mover == seat:
                word = Wording.actionWord(action, total: total)
                sticky = action == .fold || action == .allIn
            case .acted:
                break
            }
        }
        return word
    }
}
