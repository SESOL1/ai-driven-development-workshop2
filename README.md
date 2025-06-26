# 工場設備管理アプリ - AI-Driven Development ワークショップ

## プロジェクト概要

このプロジェクトは、AI-Driven Development の手法を用いて工場設備管理アプリのプロトタイプを開発するデモプロジェクトです。

### 主要機能
- 🏭 設備の稼働状況リアルタイム監視
- 🔧 予防保全・メンテナンス管理
- 📊 データ分析・可視化
- 🚨 異常検知・アラート機能

### 使用技術
- **Azure Functions**: サーバーレス処理
- **Azure SQL Database**: 設備マスター・履歴データ
- **Azure Cosmos DB**: IoTリアルタイムデータ
- **Power BI**: データ可視化・ダッシュボード
- **Python**: メイン開発言語

## 📚 実装ガイド

以下の順序でドキュメントを参照して実装を進めてください：

1. **[プロジェクト概要](./プロジェクト概要.md)**
   - システムアーキテクチャ
   - 技術スタック詳細
   - プロジェクト構造

2. **[Azure リソース作成手順](./Azure_リソース作成手順.md)**
   - Azure CLI による詳細なリソース作成手順
   - 初心者向けステップバイステップガイド
   - トラブルシューティング

3. **[開発環境セットアップ手順](./開発環境セットアップ手順.md)**
   - Python, VS Code, Azure Functions 開発環境構築
   - 必要なパッケージとツールのインストール
   - 設定ファイルの作成

4. **[プロジェクト実装手順](./プロジェクト実装手順.md)**
   - 5フェーズに分けた実装ガイド
   - データベース設計から本番デプロイまで
   - テストとパフォーマンス最適化

5. **[Power BI 設定手順](./PowerBI_設定手順.md)**
   - ダッシュボード・レポート作成
   - データソース接続
   - アラート・自動更新設定

6. **[運用・保守手順](./運用保守手順.md)**
   - 日次・週次・月次運用タスク
   - 監視・アラート設定
   - トラブルシューティング

## 🚀 クイックスタート

```bash
# 1. Azure にログイン
az login

# 2. リソースグループ作成
az group create --name rg-factory-equipment-demo --location japaneast

# 3. 詳細な手順は各ドキュメントを参照
```

## 📋 前提条件

- Azure アカウント（無料アカウント可）
- Azure CLI
- Python 3.9+
- Visual Studio Code
- Power BI Desktop

## 💡 AI-Driven Development について

このプロジェクトは AI-Driven Development の実践例として設計されています：
- 要件定義から実装まで AI を活用
- 自動生成されたコードとドキュメント
- 継続的な改善とベストプラクティスの実装

## ⚠️ 注意事項

- このプロジェクトは学習・デモ目的です
- Azure リソースの利用には料金が発生する可能性があります
- 本番環境では追加のセキュリティ対策が必要です

## 🔗 関連リンク

- [AI-Driven Development Workshop](https://dev-lab-io.github.io/aoai/scenario2/home)
- [Azure ドキュメント](https://docs.microsoft.com/ja-jp/azure/)
- [Power BI ドキュメント](https://docs.microsoft.com/ja-jp/power-bi/)
