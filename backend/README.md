# バックエンドデータ実装ガイド

## 概要
工場設備監視システムのバックエンド側で使用するデータモデル、サンプルデータ、およびデータベース設定に関する実装ガイドです。

## 実装されたコンポーネント

### 1. Azure SQL Database 関連

#### 1.1 テーブル作成スクリプト
**ファイル**: `backend/database/azure-sql-database-tables.sql`

**含まれるテーブル**:
- `User` - ユーザー管理
- `Equipment` - 設備マスター
- `Sensor` - センサーマスター
- `AnomalyLog` - 異常検知ログ
- `Alert` - アラート管理
- `MaintenanceSchedule` - メンテナンス予定
- `MaintenanceHistory` - メンテナンス実績
- `DashboardConfig` - ダッシュボード設定

**実行方法**:
```bash
# Azure SQL Database に接続してスクリプトを実行
sqlcmd -S your-server.database.windows.net -d FactoryMonitoringSystem -U your-username -P your-password -i azure-sql-database-tables.sql
```

#### 1.2 サンプルデータ挿入スクリプト
**ファイル**: `backend/database/sample-data-insert.sql`

**データ件数**:
- ユーザー: 6件
- 設備: 10件
- センサー: 30件
- 異常ログ: 7件
- アラート: 6件
- メンテナンス予定: 7件
- メンテナンス実績: 5件
- ダッシュボード設定: 3件

**実行方法**:
```bash
# テーブル作成後にサンプルデータを挿入
sqlcmd -S your-server.database.windows.net -d FactoryMonitoringSystem -U your-username -P your-password -i sample-data-insert.sql
```

### 2. Azure Cosmos DB NoSQL API 関連

#### 2.1 サンプルセンサーデータ
**ファイル**: `backend/cosmosdb/sensor-data-sample.json`

**データ構造**:
```json
{
  "id": "sensor_data_001",
  "sensorId": 1,
  "equipmentId": 1,
  "sensorType": "temperature",
  "value": 45.2,
  "unit": "℃",
  "timestamp": "2024-12-19T10:00:00.000Z",
  "status": "normal",
  "location": {
    "equipmentName": "生産ライン1号機",
    "area": "第1工場A区域",
    "coordinates": {"latitude": 35.6762, "longitude": 139.6503}
  },
  "metadata": {
    "quality": "good",
    "calibrationDate": "2024-11-15T00:00:00.000Z",
    "threshold": {"min": 10.0, "max": 80.0}
  }
}
```

#### 2.2 セットアップ手順書
**ファイル**: `backend/cosmosdb/CosmosDB_セットアップ手順書.md`

**含まれる手順**:
1. Azure CLIでのログインとセットアップ
2. Cosmos DBアカウントの作成
3. データベースとコンテナの作成
4. インデックスポリシーの設定
5. サンプルデータのインポート
6. 監視とアラートの設定
7. セキュリティ設定
8. トラブルシューティング

## データモデルの特徴

### Azure SQL Database (構造化データ)
- **用途**: マスターデータ、履歴データ、設定データ
- **特徴**: ACID特性、複雑なクエリ、トランザクション
- **保存データ**:
  - 設備・センサーマスター情報
  - ユーザー管理情報
  - メンテナンス履歴
  - 異常検知ログ
  - システム設定

### Azure Cosmos DB NoSQL API (半構造化データ)
- **用途**: リアルタイムデータ、IoTデータ、高速アクセス
- **特徴**: 高スループット、低レイテンシ、水平スケーリング
- **保存データ**:
  - リアルタイムセンサーデータ
  - イベントストリーム
  - 一時的なアラートデータ

## サンプルデータの内容

### 設備データ
1. **生産設備**:
   - 生産ライン1号機・2号機
   - 各種センサー（温度、振動、電流、稼働状態）

2. **搬送設備**:
   - 搬送コンベア1・2
   - 速度・電流・稼働状態センサー

3. **補助設備**:
   - 冷却ポンプ1・2
   - エアコンプレッサ1
   - 各種監視センサー

4. **検査・処理設備**:
   - 品質検査装置1
   - 包装機械1
   - 廃水処理装置

### ユーザーデータ
- 管理者（admin01）
- 工場長（manager01）
- 技術者（tech01, tech02）
- 作業員（operator01, operator02）

### 異常・アラートデータ
- 温度異常、振動異常
- 流量低下、圧力異常
- pH異常、速度低下
- 各レベル別のアラート設定

## Azure CLI コマンド例

### SQL Database 作成
```bash
# リソースグループ作成
az group create --name rg-factory-monitoring --location japaneast

# SQL Server 作成
az sql server create \
  --name sql-factory-monitoring \
  --resource-group rg-factory-monitoring \
  --location japaneast \
  --admin-user sqladmin \
  --admin-password YourPassword123!

# SQL Database 作成
az sql db create \
  --resource-group rg-factory-monitoring \
  --server sql-factory-monitoring \
  --name FactoryMonitoringSystem \
  --service-objective Basic
```

### Cosmos DB 作成
```bash
# Cosmos DB アカウント作成
az cosmosdb create \
  --name cosmos-factory-monitoring \
  --resource-group rg-factory-monitoring \
  --location japaneast \
  --kind GlobalDocumentDB

# データベース作成
az cosmosdb sql database create \
  --account-name cosmos-factory-monitoring \
  --resource-group rg-factory-monitoring \
  --name FactoryMonitoringDB \
  --throughput 400

# コンテナ作成
az cosmosdb sql container create \
  --account-name cosmos-factory-monitoring \
  --resource-group rg-factory-monitoring \
  --database-name FactoryMonitoringDB \
  --name SensorData \
  --partition-key-path "/equipmentId" \
  --throughput 400
```

## 開発環境での使用方法

### 1. ローカル開発環境
```bash
# SQL Server Developer Edition を使用
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourPassword123!" \
  -p 1433:1433 --name sql-dev \
  -d mcr.microsoft.com/mssql/server:2022-latest

# Cosmos DB Emulator を使用
docker run -p 8081:8081 -p 10251:10251 -p 10252:10252 -p 10253:10253 -p 10254:10254 \
  -m 3g --cpus=2.0 --name=test-linux-emulator \
  -e AZURE_COSMOS_EMULATOR_PARTITION_COUNT=10 \
  -e AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE=true \
  mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
```

### 2. 接続文字列の設定
```bash
# SQL Database 接続文字列
SQLDB_CONNECTION_STRING="Server=tcp:sql-factory-monitoring.database.windows.net,1433;Initial Catalog=FactoryMonitoringSystem;Persist Security Info=False;User ID=sqladmin;Password=YourPassword123!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Cosmos DB 接続文字列
COSMOSDB_CONNECTION_STRING="AccountEndpoint=https://cosmos-factory-monitoring.documents.azure.com:443/;AccountKey=your-primary-key-here;"
```

## 次のステップ

1. **Azure Functions の実装**
   - データ処理ロジック
   - IoTデータ収集
   - 異常検知アルゴリズム

2. **Web API の開発**
   - REST APIエンドポイント
   - 認証・認可
   - データ取得・更新処理

3. **監視・アラート機能**
   - リアルタイム監視
   - 通知システム
   - ダッシュボード連携

4. **CI/CD パイプライン**
   - 自動デプロイ
   - テスト自動化
   - インフラ構成管理

---

**注意事項**:
- 本番環境では適切なセキュリティ設定を行ってください
- リソースの使用量に応じてスケーリング設定を調整してください
- 定期的なバックアップとモニタリングを実施してください