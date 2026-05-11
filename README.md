# KabukichoQuiz

歌舞伎町のネオン感、地雷系キャラクター、クイズを組み合わせたiOSアプリ企画です。

難易度ごとにキャラクターを分け、Easyはやさしく、Mediumは少し強気に、Hardは重めの空気で出題します。初期セットアップでは、タイトル案、キャラクター設定、UI向けPNG素材、生成スクリプトを用意しています。

## ファイル構成

```text
KabukichoQuiz/
├── Assets/
│   ├── Characters/
│   │   ├── easy_character.png
│   │   ├── medium_character.png
│   │   └── hard_character.png
│   ├── Icons/
│   │   └── app_icon.png
│   └── UI/
│       ├── background_quiz.png
│       ├── button_choice.png
│       ├── button_correct.png
│       ├── button_wrong.png
│       └── splash_background.png
├── character_design.md
├── generate_assets.js
├── README.md
└── title_proposals.md
```

## アセット生成

```powershell
node .\generate_assets.js
```

`OPENAI_API_KEY` がある場合はDALL-E 3 APIで画像を生成します。未設定の場合は、Node.js組み込みモジュールだけで単色のプレースホルダーPNGを生成します。

## 次のステップ

1. タイトル案から正式名を決める。
2. キャラクター名と口調を確定する。
3. Xcodeプロジェクトを作成し、Assets配下のPNGを登録する。
4. クイズ問題データの形式を決める。
5. 難易度別の画面遷移と結果画面を作る。
