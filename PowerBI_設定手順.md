# Power BI 設定手順

## 概要

工場設備管理アプリのデータを可視化するため、Power BI を使用してダッシュボードとレポートを作成する手順を説明します。

## 前提条件

- [Azure リソース作成手順](./Azure_リソース作成手順.md) が完了していること
- [プロジェクト実装手順](./プロジェクト実装手順.md) が完了していること
- Power BI Pro または Premium ライセンスがあること（試用版でも可能）
- Power BI Desktop がインストールされていること

## ステップ 1: Power BI Desktop のインストール

### 1.1 Power BI Desktop のダウンロード

```bash
# Windows の場合
winget install Microsoft.PowerBIDesktop

# または Microsoft Store からインストール
```

**手動インストールの場合:**
1. [Power BI Desktop ダウンロードページ](https://powerbi.microsoft.com/ja-jp/desktop/) にアクセス
2. 「無料でダウンロード」をクリック
3. ダウンロードしたファイルを実行してインストール

## ステップ 2: データソースの接続設定

### 2.1 Azure SQL Database への接続

Power BI Desktop を起動し、以下の手順でデータソースに接続します：

1. **「データを取得」をクリック**
2. **「Azure」→「Azure SQL Database」を選択**
3. **接続情報を入力:**
   - サーバー: `<サーバー名>.database.windows.net`
   - データベース: `FactoryEquipmentDB`
   - データ接続モード: `Import` または `DirectQuery`
4. **認証情報を入力:**
   - ユーザー名: `sqladmin`
   - パスワード: `P@ssw0rd123!`

### 2.2 Azure Cosmos DB への接続

1. **「データを取得」をクリック**
2. **「Azure」→「Azure Cosmos DB」を選択**
3. **接続情報を入力:**
   - アカウントエンドポイント: `https://<アカウント名>.documents.azure.com:443/`
   - データベース: `EquipmentData`
   - コレクション: `SensorData`

### 2.3 Azure Functions API への接続

1. **「データを取得」をクリック**
2. **「Web」→「Web」を選択**
3. **API エンドポイントを入力:**
   - URL: `https://func-factory-equipment-demo-<タイムスタンプ>.azurewebsites.net/api/GetEquipmentAnalytics`

## ステップ 3: データモデルの設計

### 3.1 テーブル間のリレーションシップ設定

```bash
# Power BI Desktop のモデルビューで以下のリレーションシップを作成
```

**リレーションシップ設定:**
- Equipment テーブル ← MaintenanceHistory テーブル (equipment_id)
- Equipment テーブル ← Alerts テーブル (equipment_id)
- Equipment テーブル ← SensorData テーブル (equipment_id)

### 3.2 計算列の作成

**稼働率の計算:**
```dax
稼働率 = 
DIVIDE(
    SUM(SensorData[OperatingTime]),
    SUM(SensorData[TotalTime])
) * 100
```

**ダウンタイムの計算:**
```dax
ダウンタイム = 
SUM(SensorData[TotalTime]) - SUM(SensorData[OperatingTime])
```

**メンテナンス頻度の計算:**
```dax
メンテナンス頻度 = 
CALCULATE(
    COUNT(MaintenanceHistory[maintenance_id]),
    DATESINPERIOD(MaintenanceHistory[maintenance_date], TODAY(), -12, MONTH)
)
```

### 3.3 メジャーの作成

**平均稼働時間:**
```dax
平均稼働時間 = 
AVERAGE(SensorData[OperatingTime])
```

**アラート数:**
```dax
アラート数 = 
CALCULATE(
    COUNT(Alerts[alert_id]),
    Alerts[status] = "Open"
)
```

**予測メンテナンス日数:**
```dax
予測メンテナンス日数 = 
DATEDIFF(
    TODAY(),
    MAX(Equipment[next_maintenance_date]),
    DAY
)
```

## ステップ 4: ダッシュボードの作成

### 4.1 概要ダッシュボード

**主要KPI表示:**
- 全体稼働率 (ゲージチャート)
- 総設備数 (カードビジュアル)
- アクティブアラート数 (カードビジュアル)
- 予定メンテナンス数 (カードビジュアル)

**設備稼働状況:**
- 設備別稼働率 (横棒グラフ)
- 時間別稼働パターン (折れ線グラフ)
- 設備ステータス分布 (ドーナツグラフ)

### 4.2 設備監視ダッシュボード

**リアルタイム監視:**
- 設備温度トレンド (折れ線グラフ)
- 振動レベル表示 (ゲージチャート)
- 電流値監視 (面グラフ)

**アラート管理:**
- アラート一覧 (テーブル)
- 重要度別アラート数 (積み上げ縦棒グラフ)
- 設備別アラート発生頻度 (ヒートマップ)

### 4.3 メンテナンス管理ダッシュボード

**メンテナンススケジュール:**
- 今月のメンテナンス予定 (ガントチャート風テーブル)
- 設備別メンテナンス履歴 (タイムライン)
- メンテナンスコスト推移 (折れ線グラフ)

**予防保全分析:**
- 故障予測 (散布図)
- メンテナンス効果分析 (複合グラフ)
- 部品交換頻度 (マトリックス)

### 4.4 分析ダッシュボード

**パフォーマンス分析:**
- 設備効率比較 (レーダーチャート)
- 生産性トレンド (面グラフ)
- エネルギー効率分析 (散布図)

**コスト分析:**
- 運用コスト内訳 (円グラフ)
- 設備別コスト比較 (ウォーターフォールチャート)
- ROI分析 (組み合わせグラフ)

## ステップ 5: 自動更新の設定

### 5.1 データソースの資格情報設定

```bash
# Power BI Service での資格情報設定
```

1. **Power BI Service にサインイン**
2. **「設定」→「データセット」を選択**
3. **該当データセットの「設定」をクリック**
4. **「データソースの資格情報」で認証情報を更新**

### 5.2 更新スケジュールの設定

1. **「スケジュールされた更新」セクションで設定**
2. **更新頻度を選択:** 
   - 日次: 午前6時、午後6時
   - 時間別: 1時間ごと（プレミアムの場合）
3. **失敗時の通知設定を有効化**

### 5.3 リアルタイム更新の設定

**Azure Functions との連携:**
```bash
# Power BI REST API を使用した自動更新
curl -X POST "https://api.powerbi.com/v1.0/myorg/datasets/<データセットID>/refreshes" \
  -H "Authorization: Bearer <アクセストークン>" \
  -H "Content-Type: application/json"
```

## ステップ 6: アラートとサブスクリプションの設定

### 6.1 データアラートの作成

1. **KPI タイルで「アラート」を選択**
2. **閾値を設定:**
   - 稼働率が80%を下回った場合
   - アクティブアラート数が5を超えた場合
   - 温度が50度を超えた場合
3. **通知方法を選択:**
   - メール通知
   - モバイル通知

### 6.2 レポートサブスクリプションの設定

1. **「サブスクライブ」ボタンをクリック**
2. **配信スケジュールを設定:**
   - 日次レポート: 毎朝8時
   - 週次レポート: 月曜日午前
   - 月次レポート: 月初3日以内
3. **配信先メールアドレスを設定**

## ステップ 7: モバイル向け最適化

### 7.1 Power BI Mobile レイアウトの作成

1. **Power BI Desktop で「モバイルレイアウト」を選択**
2. **重要なビジュアルを上部に配置**
3. **タッチ操作に適したサイズに調整**

### 7.2 QR コードの生成

1. **Power BI Service でダッシュボードを開く**
2. **「その他のオプション」→「QR コードの生成」**
3. **現場での迅速なアクセス用にQRコードを印刷**

## ステップ 8: セキュリティとアクセス権限

### 8.1 ワークスペースのセキュリティ設定

```bash
# Azure AD でセキュリティグループを作成
az ad group create \
    --display-name "Factory Equipment Managers" \
    --mail-nickname "FactoryEquipmentManagers"
```

### 8.2 行レベルセキュリティの設定

**RLS ルールの作成:**
```dax
[location] = USERNAME()
```

1. **Power BI Desktop で「モデリング」→「ロールの管理」**
2. **「工場A管理者」ロールを作成**
3. **フィルター条件を設定: `[location] = "工場A"`**

### 8.3 アクセス権限の付与

1. **Power BI Service でワークスペースを選択**
2. **「アクセス」をクリック**
3. **ユーザー/グループを追加:**
   - 管理者: 編集権限
   - オペレーター: 表示権限
   - 保守担当者: 表示権限

## ステップ 9: パフォーマンス最適化

### 9.1 データモデルの最適化

**不要な列の削除:**
```bash
# Power Query エディターで不要な列を削除
```

**データ型の最適化:**
- 数値データの精度を適切に設定
- 日付データのフォーマットを統一
- テキストデータの長さを制限

### 9.2 ビジュアルの最適化

**表示データの制限:**
- トップ10の設備のみ表示
- 直近3ヶ月のデータに限定
- 必要に応じてドリルダウンを活用

**集計レベルの調整:**
- 日次集計データを使用
- 時間別データは必要時のみ表示

## ステップ 10: 運用とメンテナンス

### 10.1 使用状況の監視

```bash
# Power BI 管理ポータルでの使用状況確認
```

**監視項目:**
- ダッシュボードの表示回数
- レポートのダウンロード数
- データ更新の成功率
- ユーザーアクセスパターン

### 10.2 定期的なメンテナンス

**月次メンテナンス:**
- 不要なデータセットの削除
- 権限設定の見直し
- パフォーマンスの確認

**四半期メンテナンス:**
- ダッシュボードの改善提案
- 新しい要件への対応
- セキュリティ設定の見直し

## トラブルシューティング

### よくある問題と解決方法

1. **データ更新エラー**
   ```bash
   # 資格情報の確認と更新
   # ファイアウォール設定の確認
   # データソースの接続状況確認
   ```

2. **パフォーマンス問題**
   ```bash
   # DirectQuery から Import への変更検討
   # 不要なビジュアルの削除
   # データソースのインデックス作成
   ```

3. **権限エラー**
   ```bash
   # Azure AD のグループ設定確認
   # Power BI のライセンス状況確認
   # RLS 設定の見直し
   ```

## ベストプラクティス

### ダッシュボード設計

1. **5秒ルール**: 重要な情報を5秒以内に把握できるよう設計
2. **色の統一**: 企業カラーやステータスに応じた色を統一
3. **階層構造**: 概要から詳細へのドリルダウン構造を設計

### データガバナンス

1. **データ品質**: 定期的な데이터 품질 확인
2. **文書化**: データソースとビジネスルールの文書化
3. **変更管理**: ダッシュボード変更の承認プロセス確立

## 次のステップ

Power BI の設定が完了したら、次の手順に進んでください：
- [運用・保守手順](./運用保守手順.md)

## 参考資料

- [Power BI ドキュメント](https://docs.microsoft.com/ja-jp/power-bi/)
- [DAX 関数リファレンス](https://docs.microsoft.com/ja-jp/dax/)
- [Power BI のベストプラクティス](https://docs.microsoft.com/ja-jp/power-bi/guidance/)
- [Power BI セキュリティガイド](https://docs.microsoft.com/ja-jp/power-bi/admin/service-admin-power-bi-security)