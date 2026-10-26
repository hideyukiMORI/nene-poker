# いまのタスク — NeNe Poker

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-26（80 ケース・Igo の 77 ケースと全件一致・ADR 0001） |
| Phase 1 文書とゲートの足場 | 🔄 Issue #1 |
| Phase 2 negative proof | 🔄 Issue #1 |
| Phase 3 縦切り（札と役判定から） | 🔲 別 Issue |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・コミットの形）。target は 0 本で、製品コードは無い

## 動かないもの

- 製品そのもの（札・役判定・卓のルール・AI・描画・端末は Phase 3）
- `swift test`（テスト target が無いので結線していない・ADR 0002）

## 次の 1 手

Issue #1 を閉じたあと、Phase 3-1「札と役判定（Core だけ・画面なし）」の Issue を立てる。
役の種類ごとの数の期待値は一次資料から写し、出典をテストのそばに書く。一致するまで卓のルールと画面に入らない。
