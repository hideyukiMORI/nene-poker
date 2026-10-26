# いまのタスク — NeNe Poker

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-26（80 ケース・Igo の 77 ケースと全件一致・ADR 0001） |
| Phase 1 文書とゲートの足場 | ✅ 2026-10-26（Issue #1・PR #2・ruleset 25861956） |
| Phase 2 negative proof | ✅ 2026-10-26（59 件すべて pass・GitHub 側 2 件・docs/quality/gate-proofs.md） |
| Phase 3-1 札と役判定 | ✅ 2026-10-26（Issue #3・5 枚と 7 枚の全数が公表値と一致・ADR 0005・0006） |
| Phase 3-2 卓のルール | 🔲 別 Issue |
| Phase 3-3〜3-6 画面・AI・HUD | 🔲 別 Issue |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・release 構成のテスト・コミットの形）
- Core: 札・山札（乱数源を引数で受け取る）・札の表記・役判定（7 枚から最良の 5 枚）。52 枚から 5 枚・7 枚の全数の役の数が公表値と一致

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）

- 卓のルール・AI・描画・端末

## 次の 1 手

Phase 3-2「卓のルール（Core だけ）」の Issue を立てる。ベッティング・最小レイズ・サイドポット・スプリットと端数・ヘッズアップ・ブラインドの段階・
チップの保存を、一般に使われるルールの文書を出典にして ADR とテストに書く。
