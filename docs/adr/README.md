# アーキテクチャ決定記録（ADR）

トレードオフのある判断を、**理由ごと**残す場所。正本ドキュメントが「いま何が規範か」を書くのに対し、
ADR は「なぜそう決めたか」「何を却下したか」を書く。

## 書き方

- 連番 4 桁 ＋ kebab の題名: `NNNN-short-kebab-title.md`
- `0000-template.md` を複製して書く
- 状態は `提案` / `受理` / `却下` / `置換（→ NNNN）`
- **却下した選択肢を必ず書く。** 再提案は、その理由への反論から始めること
- 受理された ADR を後から書き換えない。変えるときは新しい ADR で置き換える
- 文脈は可能な限り実データ（コード・履歴・計測・コンパイラの出力）で裏を取る

## 一覧

| ADR | 題名 | 状態 |
| --- | --- | --- |
| [0001](0001-strictness-is-mechanically-enforced.md) | 厳格さは機械で強制する | 受理 |
| [0002](0002-swift-testing-only.md) | テスト枠組みは Swift Testing だけにする | 受理 |
| [0003](0003-port-gates-from-igo.md) | ゲートと規約検査は NeNe Igo から移植し、証明はこのリポジトリで取り直す | 受理 |
| [0004](0004-target-split-and-dependency-graph.md) | target は Core・Engine・Render・Terminal・合成ルートの 5 つに分け、兄弟と同じ向きで依存させる | 受理（Terminal の標準モジュールは 0009 で置換） |
| [0005](0005-cards-and-hand-evaluation.md) | 札はランクとスートの閉じた enum、札の集まりは 64 ビットの整数、役判定は 7 枚から最良の 5 枚をビットで直接決める 1 経路 | 受理 |
| [0006](0006-published-hand-counts-and-rule-tests.md) | 役判定の正しさは、5 枚と 7 枚の全数の公表値と、21 通りの比較と、手作りの組で確かめる | 受理 |
| [0007](0007-table-rules-from-roberts-rules.md) | 卓のルールは Robert's Rules of Poker（Version 11）に従い、合法な行動の一覧・ポットの分け方・進み方を Core の 1 経路ずつにする | 受理（ポットの段の切り方は 0008 で置換） |
| [0008](0008-table-screen-and-random-players.md) | 卓の画面は 112 × 28 の大の配置で描き、札は札の地の色のブロックに ASCII で、VIEW のモードは Render の入力にだけ置く | 受理 |
| [0009](0009-terminal-loop-and-signals.md) | 端末と 1 本のループは NeNe Igo から移植し、Terminal の標準モジュールに Synchronization を足す | 受理 |
| [0010](0010-screen-photos-on-windows-terminal.md) | 実機（Windows Terminal）の画面写真で、札・4 色・VIEW の両モード・文字幅を確かめ、ハンドの終わりの席のチップを分配の後の値にする | 受理 |
| [0011](0011-equity-estimate-and-cast.md) | AI は回数で打ち切る勝率の見積もり＋ポットオッズ＋性格で選び、キャスト 4 名は性格の 4 つの値で分ける | 受理 |
| [0012](0012-cyber-hud-themes-compact-and-banter.md) | サイバー HUD の 12 テーマ・縮小版（80 × 24）・キャストの顔とセリフ（1 人 50 本） | 受理 |
