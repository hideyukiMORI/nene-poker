# ADR 0013 — 版の入力は Version.swift の 1 か所、配布物は静的リンクの 1 経路で作り、検査してから梱包する

- 状態: 受理
- 日付: 2026-10-26
- Issue: #15
- 影響する規則: ARC-006 / QLT-011 / QLT-014

## 文脈

Phase 4（公開の準備）: 版の入力 1 か所・`make release TAG=v<版>`・成果物の検査・`SHA256SUMS`・`install.sh`・README（英語が正・`README.ja.md`・先頭に実機の画面写真）。
既定の `swift build -c release` は Swift のランタイムに動的に依存し、Swift の入っていない環境では起動しない（兄弟の NeNe Gambit・Igo の実測）。
兄弟の Igo が同じ経路で v0.1.0 を公開している（Igo の ADR 0012）。配布の形は Igo から移植してよい。
**タグの push と GitHub Release の作成は、施主の確認を取ってから行う外の操作**で、この Issue ではしない（REQUIREMENTS の Q9）。

## 決定

Igo の ADR 0012 の決定を、名前を合わせて引き継ぐ。移植元は Igo のコミット 2a46f6e の `eng/package-release.sh`・`eng/release/README.txt`（中身はポーカーで書き直した）・
`install.sh`・README の構成・証明 P51〜P54。

1. 版の入力は `Sources/nene-poker/Version.swift` の `Version.current`（`0.1.0`）の 1 か所。`nene-poker --version` はそこから `nene-poker <版>` の 1 行を出す
2. 配布物は `eng/package-release.sh [v<版>]`（`make release TAG=v<版>`）だけが作る。別のビルドディレクトリ（`.release/build`）で規約検査・release 構成のテスト・
   `--static-swift-stdlib` のビルドを通し、`strip` してから検査する: x86-64 の ELF・動的依存が `ld-linux-x86-64.so.2` `libc.so.6` `libgcc_s.so.1` `libm.so.6` `libstdc++.so.6` の中だけ・
   `--version` が版と一致・タグが版と一致・同梱物が `nene-poker` `README.txt` `LICENSE` の 3 つと完全一致
3. 梱包は再現できる形（tar の並び・時刻・持ち主を固定・gzip の時刻を入れない）。`SHA256SUMS` をスクリプトが書く
4. `install.sh` は最新の Release（か `NENE_POKER_VERSION`）を落とし、`SHA256SUMS` で照合してから `~/.local/bin/nene-poker` に入れる。照合に失敗したら何も入れない
5. 公開の前に、Swift の入っていない `ubuntu:22.04` のコンテナで、成果物の照合・展開・起動（`--version`・疑似端末での短い起動と `q`）を確かめる
6. 公開（タグと Release）は squash 統合後の clean な `main` から同じスクリプトで作り直し、施主の確認を取ってから行う。公開後に再ダウンロードして照合する
7. README の画面写真は実機（Windows Terminal）で撮ったものだけを置く（`docs/images/`。合成しない）。撮り方は ADR 0010

## 強制

- **active**: `eng/package-release.sh` の検査（証明 P51 タグと版の不一致・P52 静的リンクを外すと宣言外の動的依存・P53 同梱物の余計なファイル・P54 `--version` の不一致）
- **不能**: 公開の操作そのもの（施主の確認を取る手続き）。コンテナでの確認は手作業で、gate-proofs 第 5 節に記録する

## 結果

- 1 つのコマンドで、検査を通った tar.gz と `SHA256SUMS` ができる
- 失うもの: 署名・パッケージマネージャ・自動更新は無い（別の Issue。施主は言っていない）

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 版を `Package.swift` やタグから読む | SwiftPM の manifest に製品の版の欄が無い。タグは公開の後にしか無い |
| Swift のランタイムに動的にリンクして配る | Swift の入っていない WSL で起動しない |
| このリポジトリの作業でタグを push し Release を作る | 外に出る操作で、施主の確認が要る（REQUIREMENTS の Q9）。指示書もタグの push と Release の作成をしないと決めている |
