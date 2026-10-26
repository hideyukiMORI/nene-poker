# モジュール構成と依存規則 — NeNe Poker

> Status: normative（規範）/ 2026-10-26 初版
> パッケージ: SwiftPM `NeNePoker`（`Package.swift`）

モジュールグラフはアーキテクチャの一部である。**ディレクトリの命名規約だけでは依存の境界にならない。**
承認された一覧の機械可読な正本は `docs/architecture/module-graph.txt` で、規約検査が `Package.swift` の宣言と突き合わせる（ARC-002・CNF-010）。

---

## 1. 承認されたモジュール

空の「将来用 target」を作らない。下の一覧は「承認された形」で、`Package.swift` にあるのは責務が生じた target だけである（ADR 0004）。
2026-10-26 時点で `NeNePokerCore` とそのテスト target が入っている（Issue #3）。
各 target は最初の具体的な責務が生じた PR で足す（Phase 3-1 で `NeNePokerCore` とそのテストが最初に入る）。

```text
nene-poker (executable)
    合成ルート。時計・乱数（シード）・環境・起動オプションを読み、Core・Engine・Render・Terminal を組み立てて
    卓の列を回す。VIEW のモードを持つ。標準入出力への直書きと終了コードを持つ唯一の場所（ARC-006 / ARC-007）

NeNePokerTerminal
    セル格子 → ANSI の差分出力・termios・SIGWINCH・キー入力の解析。unsafe 系 API を許す唯一の区画（SWF-009）

NeNePokerRender
    卓＋HUD の値＋VIEW のモード → 文字セルの格子（配色・札のブロック・行動の履歴・セリフ）。端末を知らない。出力は値

NeNePokerEngine
    勝率の見積もり（モンテカルロ・回数で打ち切る）・行動の選び方・キャストの性格とセリフ。乱数は引数で受け取る。時計を知らない

NeNePokerCore
    札・山札（シャッフルは乱数を引数で受け取る）・役判定（7 枚→最良の 5 枚）・卓とハンドの状態・ベッティングのルール・
    ポットとサイドポット・ショーダウンと分配・ブラインドの段階。時刻・乱数源・端末・Foundation・ファイルを知らない。値型＋純粋関数
```

テスト target は `<target>Tests`（`NeNePokerCoreTests` 等）で、Swift Testing だけを import できる（SWF-016）。

---

## 2. 許可された依存グラフ

```text
NeNePokerCore      -> （無し）
NeNePokerEngine    -> NeNePokerCore
NeNePokerRender    -> NeNePokerCore, NeNePokerEngine
NeNePokerTerminal  -> NeNePokerRender                         ＋ 標準モジュール Glibc
nene-poker         -> 上の 4 つすべて（明示的な合成のためだけに） ＋ 標準モジュール Glibc
```

ここに無い依存はすべて禁止である。とくに:

- Core / Engine / Render -> Foundation・FoundationEssentials・Glibc・Dispatch: **禁止**（標準モジュールはビルドグラフでは塞げないので CNF-011 が塞ぐ）
- 宣言していない推移的な依存の import（例: Terminal -> Core）: **禁止**（SwiftPM は拒まない・M6-e。CNF-011 が塞ぐ）
- Core -> Engine、Engine -> Render 等の逆向き: 禁止（SwiftPM が `no such module` で拒み、CNF-010 が宣言を拒む）
- Terminal -> Core / Engine: 禁止（Terminal はセル格子しか知らない）
- 何か -> 合成ルート: 禁止
- Foundation: どの target からも禁止（SWF-014）

---

## 3. 各モジュールの責務

### `NeNePokerCore`

意味の正本を持つ。札・ランク・スート・役の種類・行動・ストリート・席の状態・ハンドの終わり方（閉じた enum）・札の文字列表現の拒否理由。
「行動が合法か」「ポットをどう分けるか」「役の強さの比較」の経路は Core に 1 つずつ。札の内部表記と文字列の表記は 1 つずつ（ADR 0005）。
シャッフルは乱数源を引数で受け取り、同じシードで同じ順になる。

### `NeNePokerEngine`

勝率の見積もり（残りの場札と相手の手札を乱数で埋めるモンテカルロ。回数で打ち切る。時間では打ち切らない）・ポットオッズ・行動の選び方・キャストの性格とセリフ。
行動は Core が返す合法な行動の一覧から選び、見積もりも Core の役の比較を通る（第 2 の役判定を作らない）。乱数は `inout` で受け取った乱数源からだけ引く（CNF-012 は `using:` の無い `random(...)` を拒む）。

### `NeNePokerRender`

卓と HUD の値と VIEW のモードから文字セルの 2 次元配列を作る。色は Render の配色表だけが持つ。札の表示用の表記（`As` `Td`）への変換は Render だけが持つ。
VIEW のモードの型は Render にあり、Core と Engine はそれを知らない（ADR 0004）。

### `NeNePokerTerminal`

alternate screen・カーソル非表示・24bit カラー（無ければ 256 色）・前フレームとの差分・1 フレーム 1 回の `write`・SIGWINCH・
**異常終了でも端末を必ず復元**。キー入力を閉じた enum の意図に変える。可変性の隔離区画（ARC-005）。

### `nene-poker`

依存を結ぶ。「何秒に 1 行動か」はここが決める。端末出力（起動できなかった理由 1 行）と終了コードを扱ってよい唯一の場所（ARC-006）。

---

## 4. ソースの置き場

| 種類 | 置き場 |
| --- | --- |
| production | `Sources/<target>/`（`path:` で変えない・CNF-009） |
| テスト | `Tests/<target>Tests/`（規約検査の対象。決定性・網羅性の禁止も適用する） |
| 検査設定 | `.swiftlint.yml`・`.swift-format`（直下の 2 つだけ・CNF-007） |
| 規約検査とその単体テスト | `eng/conformance.py`・`eng/tests/` |
| 依存グラフの正本 | `docs/architecture/module-graph.txt` |
| 生成コード | 無い（SwiftPM のビルドプラグインを使わない・SWF-009） |
| 道具の置き場 | `.tools/`（git 管理外。`eng/install-tools.sh` が lock の SHA-256 で入れる） |
