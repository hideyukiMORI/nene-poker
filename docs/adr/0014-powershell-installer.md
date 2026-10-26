# ADR 0014 — PowerShell からは install.ps1 で WSL の中に入れ、Windows 側には wsl.exe で起動する nene-poker.cmd だけを置く

- 状態: 受理
- 日付: 2026-10-26
- Issue: #19
- 影響する規則: FR-09 / QLT-014 / Q11

## 文脈

施主の依頼（2026-10-26）: 「PowerShell 用のワンライナーも書いておいて。nene-wire がやってるのを参考にして」。
兄弟の NeNe Wire が同じ問題を解いている（nene-wire の ADR 0012・コミット 529e5df の `install.ps1`）。
PowerShell で `curl … install.sh | bash` を打つと、`bash` は WSL の入口（`bash.exe`）なので WSL の中に入るだけで、PowerShell から `nene-poker` は使えない。
動作環境は WSL2 の Ubuntu＋Windows Terminal のまま（FR-09）。

## 決定

nene-wire の `install.ps1`（529e5df）を名前だけ替えて移植した（翻訳の案内と `--demo` の案内は nene-wire 固有なので落とした）。

1. **`install.ps1`**（`irm https://raw.githubusercontent.com/hideyukiMORI/nene-poker/main/install.ps1 | iex`）: `wsl.exe` と WSL のディストリビューションがあるかを確かめ、WSL の中で `install.sh` を流す（照合してから入れる仕組みはそのまま・QLT-014）。
   成功したら `%LOCALAPPDATA%\nene-poker\bin\nene-poker.cmd` を書き、そのフォルダをユーザーの PATH に足す
2. **`nene-poker.cmd`** の中身は `wsl.exe [-d <ディストリビューション>] --cd ~ -e .local/bin/nene-poker %*` の 1 行。PowerShell からも cmd からも起動できる
3. **失敗の仕方**: 全体を関数に包み、失敗は `return`（`irm | iex` で `exit` すると窓が閉じる）。WSL の中のインストールが失敗したら Windows 側には何も置かない
4. **選べること**（環境変数）: `NENE_POKER_DISTRO`・`NENE_POKER_VERSION`。`NENE_POKER_PATH_SCOPE` はテストでユーザーの PATH を触らないためだけのもの
5. **ASCII だけで書く**: Windows PowerShell 5.1 は BOM の無いスクリプトを地域の文字コードで読む

## 強制

- 機械では見ていない（**planned**: `make check` は PowerShell を動かせない）。実機で確かめた（2026-10-26）:
  Windows PowerShell 5.1 と PowerShell 7 で `Get-Content -Raw install.ps1 | iex`（ディストリビューション Ubuntu-22.04・一時的な LOCALAPPDATA・PATH は Process だけ）→
  WSL の中に v0.1.0 が入り、`nene-poker.cmd` が書かれ、PowerShell からも cmd からも `nene-poker --version` → `nene-poker 0.1.0`。ユーザーの PATH は変わらなかった

## 結果

- PowerShell から 1 行で入り、PowerShell でも cmd でも `nene-poker` で起動できる。実体は 1 つ（WSL の中）
- 失うもの: Windows 側にファイルと PATH の項目が 1 つずつ増える（消し方を install.ps1 の頭と README に書いた）

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| Windows ネイティブ版を作る | 端末の制御・シグナル・配布物を作り直すことになり、動作環境（FR-09）を変える |
| PowerShell の `$PROFILE` に関数を足す | PowerShell からしか使えない。cmd からも使えるよう `.cmd` にした |
| 兄弟と違う形で書く | 施主の指示は nene-wire を参考にすること。兄弟で同じ形にそろえる |
