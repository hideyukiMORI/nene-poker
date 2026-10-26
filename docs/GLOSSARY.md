# 用語集 — NeNe Poker

> Status: normative（規範）/ 2026-10-26 初版
> ここに載っている語は、コード・ドキュメント・Issue で**同じ意味**で使う。同義語を発明しない。

| 語 | 意味 | 型／場所 |
| --- | --- | --- |
| 結果（outcome） | 期待される成功・失敗を表す閉じた型 | `*Outcome` |
| 拒否理由（rejection / failure） | 結果に添える閉じた理由の集合 | `*Rejection` / `*Failure` |
| 合成ルート | 依存を結ぶ唯一の場所。時計・乱数・環境を読み、標準入出力と終了コードを持つ | `nene-poker`（executable target） |
| 描画（render） | 卓と HUD の値（と VIEW のモード）から文字セルの格子という値を作ること。端末への書き出しは含まない | `NeNePokerRender` |
| 隔離区画 | 可変性を許した唯一の場所 | ARC-005 の表 |
| 規約検査（conformance） | NeNe Poker 固有の自作ゲート | `eng/conformance.py`（CNF-NNN） |
| waiver | 1 つの規則に対する期限付きの狭い例外 | `docs/waivers/WVR-NNNN-*.md` |
| 機械強制の状態 | active / planned / 不能 / 不採用 | `docs/QUALITY_GATES.md` の強制マトリクス |
| negative proof | ゲートが意図した規則で落ちることの実測 | `docs/quality/gate-proofs.md` |
| ポーカー（Texas hold'em） | このゲーム。ノーリミット・テキサスホールデム（REQUIREMENTS の Q3）。チップは架空の点数で、現金とは関係が無い | — |
| 札（card） | 52 枚の 1 枚。ランクとスートの組。内部表記は 1 つで、表示（`As` `Td`）への変換は Render だけ | `NeNePokerCore` |
| ランク（rank） | `2`〜`9`・`T`（10）・`J`・`Q`・`K`・`A`。A はストレートでだけ 1 としても数える（ホイール） | `NeNePokerCore` |
| スート（suit） | スペード・ハート・ダイヤ・クラブ。表示は小文字の `s h d c` と 4 色（FR-07b） | `NeNePokerCore` |
| 山札（deck） | 1 ハンドで使う 52 枚。シャッフルは乱数を引数で受け取る。1 ハンドで同じ札は 2 度出ない | `NeNePokerCore` |
| 手札（hole cards） | 各席に配る伏せた 2 枚 | `NeNePokerCore` |
| 場札（board・community cards） | 卓の中央に開く 5 枚（フロップ 3・ターン 1・リバー 1） | `NeNePokerCore` |
| 役（hand category） | 5 枚の札の種類（ハイカードからストレートフラッシュまで）。7 枚から最良の 5 枚を選んで決める（FR-02a） | `NeNePokerCore` |
| 役の強さ（hand rank） | 役と、比べる順のランク（キッカーを含む）の組。2 人の役の比較は Core の 1 経路だけ | `NeNePokerCore` |
| 席（seat） | 卓の 4 つの席。画面では南（メインの子）・西・北・東に固定 | `NeNePokerCore` |
| 親（dealer button） | ハンドごとに左へ回る印。ブラインドと行動の順の起点 | `NeNePokerCore` |
| ブラインド（blinds） | 親の左の 2 席が配る前に出す強制の賭け（SB・BB）。ヘッズアップでは親が SB | `NeNePokerCore` |
| ブラインドの段階（blind level） | 卓が長くなりすぎないよう、ハンド数でブラインドを上げる段階（FR-04） | `NeNePokerCore` |
| ストリート（street） | プリフロップ・フロップ・ターン・リバーの 4 つのベッティングラウンド | `NeNePokerCore` |
| 行動（action） | フォールド・チェック・コール・ベット・レイズ・オールイン。合法な行動の一覧は Core の 1 経路だけが作る | `NeNePokerCore` |
| 最小レイズ額（minimum raise） | 直前のベットかレイズの上げ幅以上。最小レイズに届かないオールインは、上げ直しの権利を開かない | `NeNePokerCore` |
| ポット（pot）・サイドポット（side pot） | 賭けられたチップ。オールインした人が取れる分をメイン、それを超える分をサイドに分ける | `NeNePokerCore` |
| スプリット（split） | 同じ強さの役で分けること。割り切れない端数の扱いは ADR で 1 つに決める | `NeNePokerCore` |
| ショーダウン（showdown） | リバーの後に残った人が札を見せて役を比べること | `NeNePokerCore` |
| ハンド（hand） | 配ってからポットが分けられるまでの 1 回 | `NeNePokerCore` |
| 卓（table） | 4 人がチップを初期額で始め、1 人が全チップを取るまでの列（FR-04）。終わったら次の卓 | `NeNePokerCore`・合成ルート |
| 勝率の見積もり（equity estimate） | 残りの場札と相手の手札を乱数で埋めて役を比べるモンテカルロ。回数で打ち切る（FR-03）。画面には出さない | `NeNePokerEngine` |
| ポットオッズ（pot odds） | コールに要る額 ÷（ポット＋コールに要る額）。行動の選び方の入力 | `NeNePokerEngine` |
| キャスト（cast）・性格（persona） | 4 名のキャラクター。手の選び方の緩さ・攻撃性・ブラフの頻度・見積もりの回数・セリフの組（FR-06・FR-14） | `NeNePokerEngine` |
| メインの子（main player） | 卓ごとに乱数で選ぶ 1 名。南の席に座り、札は常に表（FR-07）。メインの子も AI が打つ | 合成ルート・`NeNePokerRender` |
| VIEW のモード（view mode） | 「プレイヤー以外伏せる」（`YOU`・既定）と「全員見える」（`ALL`）。表示だけの状態で、Core と Engine は知らない（FR-07a） | `NeNePokerRender`・合成ルート |
| シード（seed） | 自前の PRNG の初期値。同じシードからは同じ卓の列と同じセリフが出る（VIEW のモードに関係なく） | 合成ルートが読み、Engine に渡す |
| セル格子 | 端末の 1 画面分の文字セルの 2 次元配列。Render が作り、Terminal が差分で書く | `NeNePokerRender` |

## 使ってはいけない語

`Manager` / `Helper` / `Util` / `Utils` / `Common` を型名の語尾に使わない（SWF-010）。
役割を語る名前が思いつかないときは、その型が 2 つの責務を持っている可能性が高い。
