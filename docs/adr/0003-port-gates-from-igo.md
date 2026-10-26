# ADR 0003 — ゲートと規約検査は NeNe Igo から移植し、証明はこのリポジトリで取り直す

- 状態: 受理
- 日付: 2026-10-26
- Issue: #1
- 影響する規則: QLT-001 / QLT-007 / CNF-001〜CNF-022 / GIT-003

## 文脈

NeNe Igo（https://github.com/hideyukiMORI/nene-igo）・NeNe Reversi・NeNe Gambit は、同じ施主・同じ MIT ライセンス・同じ厳格規約で作った兄弟のリポジトリである。
施主の方針として、兄弟のゲートと規約検査・文書の形・端末と描画の土台・配布の形は、自分たちのコードとして移植してよい。
Igo は Reversi から移植した最新の形で、v0.1.0 の公開まで通っている。だから移植元は原則 Igo にする。

ただし中身を理解せずに丸ごと写すのではなく、ポーカーに要らないもの（囲碁固有の部分）を落とし、名前を合わせ、検査の証明（negative proof）は
このリポジトリで取り直す。

## 決定

Issue #1 で次のファイルを Igo から移植した。移植元は Igo の Issue #1 の squash コミット `dad2c2c`（Phase 1 の足場の形）で、
`eng/conformance.py` と `.gitignore` だけは Igo の main の `2a46f6e`（`dad2c2c` からの違いは、公開の作業場所 `.release/` を無視してよい置き場に足した 1 行だけ）から取った。

| このリポジトリのファイル | 変えたこと |
| --- | --- |
| `eng/conformance.py`・`eng/tests/test_conformance.py` | 名前を合わせた。CNF-001〜CNF-022 の番号と意味は Igo と同じ |
| `eng/measure-language.py` | 名前を合わせた。ポーカーの実装の判断材料の 3 ケース（X-i〜X-k）を足した（ADR 0001） |
| `eng/prove-gates.py` | 名前を合わせた。足場の型の範囲を 52 枚の札にした。GitHub 側の証明（P43・P46）はこのリポジトリの ruleset と run で書き直した |
| `eng/swift-strict.sh`・`eng/install-tools.sh`・`eng/install-swift.sh`・`eng/lint.sh`・`eng/swift-sources.sh`・`eng/validate-commit-message.py`・`eng/tests/test_commit_message.py`・`eng/swift.lock`・`eng/swiftlint.lock`・`eng/dependency-allowlist.txt`・`eng/ci-require-ready.sh` | 変えていない（事故の参照先は「NeNe Gambit の」と明記済み） |
| `Makefile`・`Package.swift` | 名前を合わせた（target は 0 本。`test`・`smoke` の段はまだ足さない） |
| `.swift-format`・`.swiftlint.yml`・`.swift-version`・`.githooks/commit-msg`・`.github/pull_request_template.md`・`.github/workflows/ci.yml` | 変えていない |
| `docs/` の各文書・`CLAUDE.md`・`AGENTS.md`・`README.md` | 形は Igo のまま、中身はポーカーと施主の決定とこのリポジトリの実測で書き直した |

持ってこなかったもの: 囲碁のルール・MCTS（Core と Engine はポーカーで一から書く）・キャストとセリフ（新しい 4 名で書く）・
`eng/smoke-terminal.py`・端末と描画の土台（どれも Phase 3 の使う PR で移植してこの表に足す）・配布（Phase 4 で移植する）。
Igo の作業木には書き込んでいない（読んだのは git のコミットの中身だけ）。

**証明はすべてこのリポジトリで取り直した**（`python3 eng/prove-gates.py`・[gate-proofs.md](../quality/gate-proofs.md)）。Igo・Reversi・Gambit の証明の結果は一つも写していない。
GitHub 側の証明（ruleset・draft の CI）もこのリポジトリの PR と run で取った。

## 強制

- **active**: 移植した検査はすべて、このリポジトリの証明が通ってから強制マトリクスで active にした（CNF-006 が証明行の無い active を拒否する）
- **不能**: 「移植元を理解して写したか」はレビュー事項である。この表は、次に誰かが Igo の修正を取り込むときの照合元として置く

## 結果

- 5 回分の実測と事故（draft の CI のスキップ・SwiftPM の警告・静的バイナリが黙って規則を飛ばす・Gambit の CNF-013 の穴）から生まれた検査を、最初から持てる
- 失うもの: Igo の検査器が直されても、このリポジトリには自動では入らない。検査器は製品ごとに別々に保守する

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| Reversi や Gambit から移植する | Igo は Reversi の形をそのまま受け継ぎ、そのうえ公開まで通っている。古い方を写す理由が無い |
| 検査器を共有のパッケージや submodule にする | 依存を足すことになり（CODING_RULES 第 5 節の 3 点が要る）、片方の都合の変更がもう片方のゲートを黙って変える。規約は製品ごとの「守るべきこと」を含む |
| 検査器を一から書き直す | 先に踏んだ地雷を自分で踏み直すことになる。移植してよいと施主が決めている |
| Igo の gate-proofs の結果を写す | 「設定が在ることは検査が効いている証明ではない」（ポリシー P-09）。このリポジトリの木で落ちるのを見ていない |
| Igo の main の HEAD の `prove-gates.py` を移植する | 実装済みの target のソースに違反を仕込む形で、target が 0 本の足場では動かない。足場を置いて仕込む `dad2c2c` の形を移植した |
