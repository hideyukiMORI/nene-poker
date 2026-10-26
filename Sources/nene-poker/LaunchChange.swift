import NeNePokerRender

/// 起動オプションの 1 つの値の変更（LaunchOptions の組み立ての中だけで使う）。nil は「変えない」。
struct LaunchChange {
    var seed: UInt64?
    var theme: Theme?
    var view: ViewMode?
    var moveInterval: Duration?
    var resultPause: Duration?
}
