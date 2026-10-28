# Gopher — Hello, Glass!

参考: ユーザー提供の Gopher.jpeg（左下から顔をのぞかせるGopher）。
元画像のGopher部分を切り出し、背景を透明にしてUnicode/Brailleへ変換。
顔の傾き、大きな白目、口元、元画像の切れた肩の構図を保つ。接近中はnormal-pose.pngの通常顔を縦横比を保って拡大し、0.81秒の接触後に元画像の頬を押しつけた表情へ切り替える。横への広がりと縦方向のつぶれは接触後だけに適用する。
原作Gopherのデザイン: Renée French。参考壁紙の表記: @avocadoneko。

48×24文字、26フレーム、1.90秒。遠くから接近 → 画面に衝突 → 顔が横につぶれる → 弾んで戻る → 静止。
元画像に寄せた白・水色・青・ベージュ・紺の5色（palette.json）、背景は透明。衝突後の最後のフレームがFastfetchロゴになる。

- `gopher-splat.asciimtn`: ASCII Motionで開いて編集できるネイティブプロジェクト。
- `animation/`: ASCII Motion MCPの`export_ansi`で書き出した26フレームと再生時間。
- `fastfetch-gopher.txt`: 最終フレームのFastfetch用5色テキスト。
- `play-once.sh`: 時間表に沿って一度再生。`FASTFETCH_GOPHER_SKIP_ANIMATION=1`で省略。

起動は `wezterm/gopher-startup.sh`。GUI用Homebrew PATHの補完と既存Fastfetch設定へのフォールバックを含む。
既存のFastfetchモジュール設定を使い、ロゴと5色をCLIで指定する。

制作ツールはGo製。Go 1.27.3、ImageMagick、インストール済みASCII Motion MCPとその実行環境（npm版の場合はNode.js）を使う。外部GoライブラリやPythonは不要。

dotfilesのルートから、画像変換とANSI書き出しをまとめて実行:

```sh
go -C fastfetch/gopher run . all
```

個別に実行する場合:

```sh
# 画像からプロジェクト・静止ロゴ・再生時間表を生成
go -C fastfetch/gopher run . build

# 保存済みプロジェクトからANSIフレームだけを書き出す
go -C fastfetch/gopher run . export

# 制作ツールのテスト
go -C fastfetch/gopher test ./...
```

`project.go`がImageMagickの画像データを受け取り、背景除去・5色化・Braille変換・ポーズ生成を行う。
`mcp.go`がASCII Motion MCPを専用プロセスで起動してANSIを取得する。npmキャッシュのv3.0.1を優先し、見つからなければPATH上の`ascii-motion-mcp`を使う。必要なら`export -mcp-server 実行ファイル`で指定できる。パッケージの自動ダウンロードは行わない。

MCPの作業用プロジェクトと書き出しキャッシュは一時ディレクトリに作り、終了時に削除する。全フレームの書き出しが成功してから成果物を更新する。鯉用のランチャーには依存しない。ASCII Motion本体・エディタの拡張は不要。

ASCII Motionで手編集したプロジェクトを保持する場合は、`export`だけを使う。`all`と`build`は原画からプロジェクトを生成する。
再生時は完成済みANSIをシェルで表示するため、WezTermの起動時にGo・ImageMagick・MCPは動かない。

`normal-pose.png` は元壁紙を参照して組み込みImageGenで作った接触前の原画。生成条件は `normal-pose-prompt.md` を参照。元壁紙は接触後の表情に使う。

全編を同じBraille点描・透明背景・5色に統一する。接近中だけ塗りつぶし文字やセル背景を使わず、接触後の元画像と同じ密度・質感で表示する。

接近中の小さな瞳・目の輪郭は、セル内の暗色を透明な点として抜くことで、代表色による細部の塗りつぶれを抑える。暗いセル内の白いハイライト・前歯も残す。
