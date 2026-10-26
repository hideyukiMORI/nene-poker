# ADR 0009 — 端末と 1 本のループは NeNe Igo から移植し、Terminal の標準モジュールに Synchronization を足す

- 状態: 受理（ADR 0004 の Terminal の標準モジュールを置き換える）
- 日付: 2026-10-26
- Issue: #7
- 影響する規則: ARC-005 / ARC-006 / ARC-007 / SWF-009 / SWF-013 / CNF-011 / CNF-022

## 文脈

端末（termios・alternate screen・SIGWINCH・異常終了でも戻す・キー入力・差分描画）は兄弟 4 作で同じ形に育ち、事故から生まれた規則を含む
（Gambit の 256 色の近似・Reversi の罫線の幅の問い合わせ・Igo の版）。ポーカーで違うのは、キーが `q` と `v`（Phase 3-6 で `t`）であることだけ。

シグナルハンドラから旗を立てるには、並行性の検査を通る原子的な値が要る。Igo の ADR 0008 は標準モジュール `Synchronization` の `Atomic` を使い、
Terminal の import の許可リストにだけ足した（ADR 0004 の「使うまで承認しない」をその PR で満たした）。

## 決定

1. `Sources/NeNePokerTerminal/` の 8 つのファイルを NeNe Igo の main（コミット 2a46f6e）から移植した。変えたのは、キーの意図（`t` のテーマを `v` の札の見せ方に）と、
   差分描画の下線の指定を落としたこと（Igo の石の下線は要らない・Render の `Cell` に下線の状態が無い）だけ
2. 合成ルート（`main.swift`・`Screensaver.swift`・`LaunchOptions.swift`）も Igo から移植し、`--view you|all` を足した。並行の形は 1 つで、合成ルートの 1 本のループが
   `poll` で待ち、シグナルハンドラは原子的な旗を立てるだけ。異常終了のシグナルだけはハンドラがその場で端末を戻してから既定の動作で死ぬ（FR-08）
3. Terminal の標準モジュールを `Glibc,Synchronization` にする（`docs/architecture/module-graph.txt`）。ほかの target の許可リストは変えない
4. `make smoke`（`eng/smoke-terminal.py`・Igo から移植）が、疑似端末で `q`・Ctrl+C・SIGTERM・SIGSEGV・大きさの変化・`v`・ASCII の枠への退避・間違った起動オプション・端末の外からの起動を見る。
   差分描画は変わったセルしか書かないので、`v` の確認は出力をなぞった最後の画面のキーの帯で見る

## 強制

- **active**: CNF-011（Terminal 以外は Synchronization を import できない）・CNF-022（並行の語）・`make smoke`（端末の復元を壊すと落ちる・証明 P49）
- **不能**: Windows Terminal での見え方は疑似端末では確かめられない（QLT-013）

## 結果

- 兄弟と同じ端末の扱いを最初から持てる
- 失うもの: Igo の Terminal が直されても自動では入らない（ADR 0003 と同じ）

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| シグナルの旗を `nonisolated(unsafe) var` の Bool で持つ | 並行性の検査を外す（M7-k）。移植元と同じく `Atomic` にした |
| 端末を一から書く | 兄弟が踏んだ地雷を踏み直す。移植してよいと施主が決めている |
| 差分描画の下線の指定を残す | 使わない状態を残すと、セルの値と端末の指定が 2 か所でずれうる |
