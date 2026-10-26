/// テストの準備に失敗した理由。
enum FixtureFailure: Error {
    case unreadable
    case rejected
}
