# 工場設備監視システム フロントエンド - ローカル実行手順書

## 概要

このドキュメントは、工場設備監視システムのフロントエンド部分をオフラインのローカル環境で動作させるための詳細な手順書です。

## システム要件

### 必須環境
- **Node.js**: バージョン 16.0.0 以上
- **npm**: バージョン 8.0.0 以上
- **Web ブラウザ**: Chrome, Firefox, Safari, Edge の最新版

### 動作確認済み環境
- Windows 10/11
- macOS 12.0 以上
- Ubuntu 20.04 以上

## インストール手順

### 1. Node.js のインストール

#### Windows の場合
1. [Node.js 公式サイト](https://nodejs.org/) にアクセス
2. 「LTS版」をダウンロード
3. ダウンロードした `.msi` ファイルを実行
4. インストールウィザードに従ってインストール

#### macOS の場合
```bash
# Homebrew を使用する場合
brew install node

# 公式インストーラーを使用する場合
# https://nodejs.org/ からダウンロードして実行
```

#### Ubuntu/Linux の場合
```bash
# Node.js 公式リポジトリから最新版をインストール
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# または snap を使用
sudo snap install node --classic
```

### 2. インストール確認

コマンドプロンプトまたはターミナルで以下のコマンドを実行し、バージョンが表示されることを確認：

```bash
node --version
npm --version
```

期待される出力例：
```
v18.17.0
9.6.7
```

## プロジェクトセットアップ

### 1. プロジェクトディレクトリに移動

```bash
cd /path/to/ai-driven-development-workshop2/frontend
```

### 2. 依存関係のインストール

```bash
npm install
```

インストール完了までに数分かかる場合があります。以下のような出力が表示されれば成功です：

```
added 675 packages, and audited 676 packages in 2m
```

### 3. プロジェクト構造の確認

正しくセットアップされている場合、以下のような構造になります：

```
frontend/
├── package.json
├── public/
│   └── index.html
├── src/
│   ├── main.js
│   ├── App.vue
│   └── components/
│       ├── Home.vue
│       └── EquipmentStatus.vue
├── data/
│   └── sample-data.json
└── node_modules/
```

## アプリケーションの起動

### 1. 開発サーバーの起動

```bash
npm run dev
```

または

```bash
npm run serve
```

### 2. 起動確認

正常に起動すると、以下のような出力が表示されます：

```
 INFO  Starting development server...
 
  App running at:
  - Local:   http://localhost:8080/
  - Network: http://192.168.1.100:8080/

  Note that the development build is not optimized.
  To create a production build, run npm run build.
```

### 3. ブラウザでのアクセス

Web ブラウザで以下のURLにアクセスします：

- **ローカル**: http://localhost:8080/
- **同一ネットワーク**: http://[ネットワークアドレス]:8080/

## 利用可能な画面

### 1. ホーム画面 (/)

- **URL**: http://localhost:8080/
- **機能**: システム全体概要、統計情報、最新アラート、稼働率グラフ
- **表示内容**:
  - システム統計（総設備数、稼働中、アラート数、全体効率）
  - 最新アラート一覧
  - 今日の稼働率グラフ
  - 本日のメンテナンス予定
  - クイックアクションボタン

### 2. 設備稼働状況画面 (/equipment-status)

- **URL**: http://localhost:8080/equipment-status
- **機能**: 詳細な設備監視、センサーデータ表示
- **表示内容**:
  - 設備一覧（カード形式）
  - エリア別フィルタリング
  - リアルタイムセンサーデータ
  - 設備詳細モーダル
  - アラート管理

## 主要機能の使用方法

### 1. 画面遷移

- **ホーム画面**: ナビゲーションバーの「ホーム」をクリック
- **設備稼働状況画面**: ナビゲーションバーの「設備稼働状況」をクリック

### 2. データ更新

- **手動更新**: 各画面の「データ更新」ボタンをクリック
- **自動更新**: 実装されていない（サンプルデータのため）

### 3. エリアフィルタリング（設備稼働状況画面）

- 画面右上のドロップダウンで「エリアA」「エリアB」「エリアC」を選択
- 「全エリア」で全設備を表示

### 4. 設備詳細表示

- 設備カードの「詳細表示」ボタンをクリック
- モーダルウィンドウで詳細情報を表示
- 背景クリックまたは「×」ボタンで閉じる

## トラブルシューティング

### 1. 起動時エラー

#### ポート番号競合エラー
```
Error: listen EADDRINUSE: address already in use :::8080
```

**解決方法**:
```bash
# 使用中のプロセスを確認
netstat -tulpn | grep 8080

# プロセスを終了してから再起動
npm run dev
```

#### 依存関係エラー
```
Module not found: Error: Can't resolve...
```

**解決方法**:
```bash
# node_modules を削除して再インストール
rm -rf node_modules
npm install
```

### 2. ブラウザ表示エラー

#### 白い画面が表示される場合
1. ブラウザの開発者ツール（F12）でコンソールエラーを確認
2. ブラウザのキャッシュをクリア（Ctrl+Shift+R）
3. 別のブラウザで動作確認

#### 画面レイアウトが崩れる場合
1. ブラウザの拡大率を100%に設定
2. CSS が正しく読み込まれているか確認
3. レスポンシブデザインのため、画面幅を調整

### 3. 開発サーバーが停止しない場合

```bash
# Ctrl+C で停止できない場合
ps aux | grep node
kill -9 [プロセスID]
```

### 4. Windows 固有の問題

#### PowerShell 実行ポリシーエラー
```bash
# 管理者権限で PowerShell を開き、以下を実行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## サンプルデータについて

### データファイル場所
- `frontend/data/sample-data.json`

### データ内容
- **設備情報**: 6台の設備（プレス機、コンベア、ボイラー、コンプレッサー、ポンプ）
- **センサーデータ**: 温度、振動、電流、圧力など
- **アラート情報**: 警告および異常アラート
- **メンテナンス情報**: 予定および履歴

### データ更新方法

1. `sample-data.json` を編集
2. ブラウザでページを再読み込み
3. 新しいデータが反映される

## プロダクションビルド

### 1. ビルド実行

```bash
npm run build
```

### 2. ビルド結果

`dist/` フォルダに静的ファイルが生成されます：

```
dist/
├── index.html
├── css/
│   └── app.*.css
└── js/
    ├── app.*.js
    └── chunk-vendors.*.js
```

### 3. 静的ファイルの配信

```bash
# 簡易Webサーバーでテスト
npx serve dist

# または Python を使用
cd dist
python3 -m http.server 8080
```

## 追加設定・カスタマイズ

### 1. ポート番号の変更

`package.json` の scripts セクションを修正：

```json
{
  "scripts": {
    "dev": "vue-cli-service serve --port 3000"
  }
}
```

### 2. API エンドポイントの設定

将来的にバックエンドAPIと連携する場合、`src/main.js` にベースURLを設定：

```javascript
// 環境変数または設定ファイルで管理
const API_BASE_URL = process.env.VUE_APP_API_URL || 'http://localhost:5000'
```

### 3. プロキシ設定

バックエンドAPIと連携する場合、`vue.config.js` を作成：

```javascript
module.exports = {
  devServer: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true
      }
    }
  }
}
```

## 注意事項

### セキュリティ
- この環境は開発・デモ用です
- 本番環境では適切な認証・認可機能を実装してください
- HTTPSを使用してください

### パフォーマンス
- 大量のデータを扱う場合は仮想スクロールの実装を検討
- 画像やアセットは適切に最適化してください

### ブラウザサポート
- Internet Explorer は未サポート
- モバイルブラウザでの動作確認を推奨

## サポート・連絡先

### 技術的な質問
- GitHub Issues: [プロジェクトのIssues](https://github.com/SESOL1/ai-driven-development-workshop2/issues)
- 開発チーム: ai-development-team@example.com

### ドキュメント更新履歴
- **2024-12-19**: 初版作成
- **版数**: 1.0

---

**注意**: このドキュメントは工場設備監視システムのデモ版に関するものです。実際の工場環境での利用には、追加のセキュリティ対策とパフォーマンス最適化が必要です。