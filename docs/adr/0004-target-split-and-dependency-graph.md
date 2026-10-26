# ADR 0004 — target は Core・Engine・Render・Terminal・合成ルートの 5 つに分け、兄弟と同じ向きで依存させる

- 状態: 受理
- 日付: 2026-10-26
- Issue: #1
- 影響する規則: ARC-002 / ARC-003 / ARC-006 / ARC-007 / ARC-011 / CNF-010 / CNF-011

## 文脈

依存方向を物理的にする（ARC-002）には、責務ごとに SwiftPM の target を分け、禁じた向きを「import できない」状態にする必要がある。
兄弟の NeNe Gambit・NeNe Reversi・NeNe Igo は同じ形の製品（端末のスクリーンセーバー・手作りの AI・サイバー HUD）を 5 つの target で作っている（Igo の ADR 0004）。
Igo は v0.1.0 の公開まで、この 5 つの target と target 間の依存の向きを変えずに来ている（Igo の main `2a46f6e` の `docs/architecture/module-graph.txt` は、
`dad2c2c` から Terminal の標準モジュールに `Synchronization` を足しただけ。Igo の ADR 0008）。

Phase 0 の実測で、SwiftPM は兄弟の target の import を拒むが、**推移的な依存の import は拒まない**ことを確かめた（M6-a・M6-e・M6-f）。

ポーカーで兄弟と違うのは中身だけで、層の分け方を変える理由は見つからなかった。

- Core: 札・役判定・ベッティングのルール・サイドポットとスプリットは時計も乱数源も要らない純粋関数で書ける。シャッフルは乱数を引数で受け取る
- Engine: 勝率の見積もり（モンテカルロ）は乱数を使うが、乱数源は引数で受け取れる（兄弟の探索と同じ扱い）。見積もりも Core の役の比較を通る
- Render・Terminal: 席・札・場札・ポットが増えるだけで、「卓＋HUD の値 → セル格子 → ANSI の差分」の形は同じ。**VIEW のモードは Render の入力にだけ現れる**

## 決定

依存グラフの正本は `docs/architecture/module-graph.txt` とし、次の 5 つの target とそれぞれのテスト target を承認する。

```text
NeNePokerCore      札・山札・役判定・卓とハンドの状態・ベッティングのルール・ポットとサイドポット・ショーダウンと分配・ブラインドの段階（依存なし）
NeNePokerEngine    勝率の見積もり・行動の選び方・キャストの性格とセリフ（-> Core）
NeNePokerRender    卓＋HUD の値＋VIEW のモード → 文字セルの格子（-> Core, Engine）
NeNePokerTerminal  セル格子 → ANSI の差分出力・termios・シグナル・キー入力（-> Render ＋ Glibc・unsafe を許す唯一の区画）
nene-poker         合成ルート。時計・乱数・環境・起動オプションを読む唯一の場所（-> 上の 4 つ ＋ Glibc）
```

- Render が Engine に依存するのは、キャストの名前とセリフ（Engine の性格の値）を画面に出すため（兄弟と同じ）
- VIEW のモードの型は Render に置く。Core と Engine は Render を import できない（逆向き）ので、モードが対局の進み方に入り込む経路が物理的に無い
- target は最初の具体的な責務が生じた PR で `Package.swift` に足す。Phase 1 の `Package.swift` の target は 0 本
- 兄弟が後から広げた所（Igo の Terminal の `Synchronization`）は、このリポジトリで同じ必要が生じた PR で、この ADR を置き換える ADR とともに足す。使うまで承認しない

## 強制

- **active** → SwiftPM の target グラフ（兄弟の import と循環を拒む）＋CNF-010（`Package.swift` と正本の一致・正本の循環・合成ルートは 1 つ）＋
  CNF-011（各ファイルの import が、正本で宣言した直接の依存と `std=` の標準モジュールだけであること。推移的な依存も標準モジュールもここで塞ぐ）

## 結果

- 「Core は時計も端末も知らない」「Terminal は卓を知らない」「VIEW のモードは対局を変えない」が、レビューではなく import の失敗で守られる
- 失うもの: Terminal のテストで卓の局面から格子を作るような便利な書き方はできない

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 1 つの target にまとめ、ディレクトリで分ける | ディレクトリの命名だけでは依存の境界にならない（PROJECT_LAYOUT 冒頭） |
| 役判定を Core から別の target に分ける | 役判定はショーダウンの分配（Core）と勝率の見積もり（Engine）の両方が使う意味の正本で、Core の外に出すと Core が別の target に依存する。分けても禁じる向きが増えない |
| VIEW のモードを Core の卓の状態に持たせる | 表示だけの状態が対局の値に入り、`v` を押すと対局の値が変わる形になる。FR-07a の「表示だけ」を依存方向で守れなくなる |
| Render を Engine に依存させず、セリフを合成ルートから文字列で渡す | キャストの名前とセリフの正本が Engine と合成ルートの 2 か所に割れる（ARC-001） |
| Igo の最終形（`Synchronization` を含む）を最初から承認する | 使っていない許可は「空の将来用 target を作らない」と同じ理由で置かない。必要になった PR で根拠ごと足す |
| `--explicit-target-dependency-import-check error` に推移的な import を任せる | 実測で拒まなかった（M6-f） |
