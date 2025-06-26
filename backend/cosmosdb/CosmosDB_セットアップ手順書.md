# Azure Cosmos DB NoSQL API セットアップ手順書

## 概要
工場設備監視システムのリアルタイムセンサーデータを管理するため、Azure Cosmos DB NoSQL APIを設定し、サンプルデータをインポートする詳細な手順です。

## 前提条件

### 必要なツール
- Azure CLI (最新版)
- Azure アカウント（有効なサブスクリプション）
- Webブラウザ（Azure Portal用）

### 準備事項
1. Azure アカウントにログイン
2. リソースグループの作成
3. 適切な権限の確認（Contributor以上）

## 手順1: Azure CLIでのログインとセットアップ

### 1.1 Azure CLIでログイン
```bash
# Azureにログイン
az login

# サブスクリプション一覧を確認
az account list --output table

# 使用するサブスクリプションを設定（必要に応じて）
az account set --subscription "your-subscription-id"
```

### 1.2 リソースグループの作成
```bash
# リソースグループを作成
az group create \
  --name "rg-factory-monitoring" \
  --location "japaneast"
```

## 手順2: Azure Cosmos DB アカウントの作成

### 2.1 Cosmos DBアカウントの作成
```bash
# Cosmos DBアカウントを作成
az cosmosdb create \
  --name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --location "japaneast" \
  --kind "GlobalDocumentDB" \
  --default-consistency-level "Session" \
  --enable-multiple-write-locations false \
  --enable-automatic-failover true
```

**実行時間**: 約5-10分かかります。

### 2.2 接続文字列の取得
```bash
# プライマリ接続文字列を取得
az cosmosdb keys list \
  --name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --type "connection-strings" \
  --query "connectionStrings[0].connectionString" \
  --output tsv
```

**重要**: この接続文字列は後で使用するため、安全な場所に保存してください。

## 手順3: データベースとコンテナの作成

### 3.1 データベースの作成
```bash
# データベースを作成
az cosmosdb sql database create \
  --account-name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --name "FactoryMonitoringDB" \
  --throughput 400
```

### 3.2 センサーデータ用コンテナの作成
```bash
# センサーデータ用コンテナを作成
az cosmosdb sql container create \
  --account-name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --database-name "FactoryMonitoringDB" \
  --name "SensorData" \
  --partition-key-path "/equipmentId" \
  --throughput 400
```

### 3.3 リアルタイムアラート用コンテナの作成
```bash
# リアルタイムアラート用コンテナを作成
az cosmosdb sql container create \
  --account-name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --database-name "FactoryMonitoringDB" \
  --name "RealTimeAlerts" \
  --partition-key-path "/equipmentId" \
  --throughput 400
```

### 3.4 イベントログ用コンテナの作成
```bash
# イベントログ用コンテナを作成
az cosmosdb sql container create \
  --account-name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --database-name "FactoryMonitoringDB" \
  --name "EventLogs" \
  --partition-key-path "/equipmentId" \
  --throughput 400
```

## 手順4: インデックスポリシーの設定

### 4.1 SensorDataコンテナのインデックス設定
```bash
# インデックスポリシーJSONファイルを作成（index-policy-sensor.json）
cat > index-policy-sensor.json << 'EOF'
{
  "indexingMode": "consistent",
  "automatic": true,
  "includedPaths": [
    {
      "path": "/*"
    }
  ],
  "excludedPaths": [
    {
      "path": "/\"_etag\"/?"
    }
  ],
  "compositeIndexes": [
    [
      {
        "path": "/equipmentId",
        "order": "ascending"
      },
      {
        "path": "/timestamp",
        "order": "descending"
      }
    ],
    [
      {
        "path": "/sensorType",
        "order": "ascending"
      },
      {
        "path": "/timestamp",
        "order": "descending"
      }
    ]
  ]
}
EOF

# インデックスポリシーを適用
az cosmosdb sql container update \
  --account-name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --database-name "FactoryMonitoringDB" \
  --name "SensorData" \
  --idx @index-policy-sensor.json
```

## 手順5: Azure Portal での確認

### 5.1 Azure Portal アクセス
1. [Azure Portal](https://portal.azure.com)にアクセス
2. 「Cosmos DB」で検索
3. 作成した「cosmos-factory-monitoring」をクリック

### 5.2 データエクスプローラーでの確認
1. 左メニューから「データエクスプローラー」を選択
2. 「FactoryMonitoringDB」データベースを展開
3. 以下のコンテナが作成されていることを確認：
   - SensorData
   - RealTimeAlerts
   - EventLogs

## 手順6: サンプルデータのインポート

### 6.1 Azure Portal でのデータインポート

#### 方法1: データエクスプローラーを使用
1. Azure Portal の Cosmos DB アカウントで「データエクスプローラー」を開く
2. 「SensorData」コンテナを選択
3. 「New Item」をクリック
4. 以下のサンプルJSONを貼り付け（1件ずつ）：

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
    "coordinates": {
      "latitude": 35.6762,
      "longitude": 139.6503
    }
  },
  "metadata": {
    "quality": "good",
    "calibrationDate": "2024-11-15T00:00:00.000Z",
    "threshold": {
      "min": 10.0,
      "max": 80.0
    }
  }
}
```

#### 方法2: Azure CLI でのJSONファイルインポート

**注意**: 残念ながら、Azure CLI では直接JSONファイルをインポートするコマンドはありません。プログラムによるインポートが必要です。

### 6.2 プログラムによるデータインポート用のPythonスクリプト

```bash
# 必要なライブラリをインストール
pip install azure-cosmos python-dotenv

# インポート用Pythonスクリプトを作成
cat > import_sample_data.py << 'EOF'
import json
import os
from azure.cosmos import CosmosClient, PartitionKey
from azure.cosmos.exceptions import CosmosResourceExistsError

# 接続設定
COSMOS_ENDPOINT = "https://cosmos-factory-monitoring.documents.azure.com:443/"
COSMOS_KEY = "YOUR_PRIMARY_KEY_HERE"  # 手順2.2で取得したキーを設定
DATABASE_NAME = "FactoryMonitoringDB"
CONTAINER_NAME = "SensorData"

def import_sample_data():
    # Cosmos DB クライアントを初期化
    client = CosmosClient(COSMOS_ENDPOINT, COSMOS_KEY)
    
    # データベースとコンテナを取得
    database = client.get_database_client(DATABASE_NAME)
    container = database.get_container_client(CONTAINER_NAME)
    
    # サンプルデータを読み込み
    with open('sensor-data-sample.json', 'r', encoding='utf-8') as f:
        sample_data = json.load(f)
    
    # データをインポート
    imported_count = 0
    for item in sample_data:
        try:
            container.create_item(body=item)
            imported_count += 1
            print(f"インポート完了: {item['id']}")
        except CosmosResourceExistsError:
            print(f"既に存在します: {item['id']}")
        except Exception as e:
            print(f"エラー: {item['id']} - {str(e)}")
    
    print(f"インポート完了: 総件数 {imported_count}")

if __name__ == "__main__":
    import_sample_data()
EOF
```

### 6.3 Pythonスクリプトの実行
```bash
# スクリプトを実行してサンプルデータをインポート
python import_sample_data.py
```

## 手順7: データの確認とクエリ

### 7.1 Azure Portal でのデータ確認
1. データエクスプローラーで「SensorData」コンテナを選択
2. 「Items」タブでインポートされたデータを確認

### 7.2 サンプルクエリの実行
Azure Portal のクエリエディターで以下のクエリを実行：

```sql
-- 全てのセンサーデータを取得
SELECT * FROM c

-- 特定の設備のデータを取得
SELECT * FROM c WHERE c.equipmentId = 1

-- 異常状態のセンサーデータを取得
SELECT * FROM c WHERE c.status != "normal"

-- 温度センサーのデータを時間順で取得
SELECT * FROM c 
WHERE c.sensorType = "temperature" 
ORDER BY c.timestamp DESC

-- 過去1時間のデータを取得
SELECT * FROM c 
WHERE c.timestamp >= DateTimeAdd("hour", -1, GetCurrentDateTime())
```

## 手順8: 監視とアラートの設定

### 8.1 診断設定の有効化
```bash
# Log Analytics ワークスペースを作成
az monitor log-analytics workspace create \
  --resource-group "rg-factory-monitoring" \
  --workspace-name "law-factory-monitoring" \
  --location "japaneast"

# 診断設定を有効化
az monitor diagnostic-settings create \
  --name "cosmosdb-diagnostics" \
  --resource "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-factory-monitoring/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-factory-monitoring" \
  --workspace "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-factory-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-factory-monitoring" \
  --logs '[{"category":"DataPlaneRequests","enabled":true}]' \
  --metrics '[{"category":"Requests","enabled":true}]'
```

### 8.2 アラートルールの作成
```bash
# Request Units使用量のアラートを作成
az monitor metrics alert create \
  --name "CosmosDB-HighRU" \
  --resource-group "rg-factory-monitoring" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-factory-monitoring/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-factory-monitoring" \
  --condition "avg Requests/TotalRequestUnits > 800" \
  --window-size "5m" \
  --evaluation-frequency "1m" \
  --severity 2 \
  --description "Cosmos DB Request Units usage is high"
```

## 手順9: セキュリティ設定

### 9.1 ファイアウォール設定
```bash
# 特定のIPアドレスからのアクセスを許可
az cosmosdb update \
  --name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --ip-range-filter "YOUR_IP_ADDRESS"
```

### 9.2 Virtual Network サービスエンドポイント（オプション）
```bash
# VNetを作成（必要に応じて）
az network vnet create \
  --name "vnet-factory" \
  --resource-group "rg-factory-monitoring" \
  --location "japaneast" \
  --address-prefix "10.0.0.0/16"

# サブネットを作成
az network vnet subnet create \
  --name "subnet-cosmos" \
  --resource-group "rg-factory-monitoring" \
  --vnet-name "vnet-factory" \
  --address-prefix "10.0.1.0/24" \
  --service-endpoints "Microsoft.AzureCosmosDB"

# VNet ルールを追加
az cosmosdb network-rule add \
  --name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --subnet "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-factory-monitoring/providers/Microsoft.Network/virtualNetworks/vnet-factory/subnets/subnet-cosmos"
```

## 手順10: バックアップ設定の確認

### 10.1 自動バックアップ設定の確認
```bash
# バックアップポリシーを確認
az cosmosdb show \
  --name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --query "backupPolicy"
```

### 10.2 継続的バックアップの有効化（オプション）
```bash
# 継続的バックアップを有効化
az cosmosdb update \
  --name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --backup-policy-type "Continuous"
```

## トラブルシューティング

### よくある問題と解決策

#### 1. 接続エラー
**症状**: アプリケーションからCosmosDBに接続できない
**解決策**:
- ファイアウォール設定を確認
- 接続文字列が正しいことを確認
- IPアドレス制限を確認

#### 2. スループット不足
**症状**: 429エラー（Rate Limited）が発生
**解決策**:
```bash
# コンテナのスループットを増加
az cosmosdb sql container throughput update \
  --account-name "cosmos-factory-monitoring" \
  --resource-group "rg-factory-monitoring" \
  --database-name "FactoryMonitoringDB" \
  --name "SensorData" \
  --throughput 1000
```

#### 3. パーティション分散の問題
**症状**: ホットパーティションが発生
**解決策**:
- パーティションキーの設計を見直し
- より分散しやすいキーに変更

## 運用チェックリスト

### 日次確認項目
- [ ] Request Units使用量の確認
- [ ] エラー率の確認
- [ ] データ取り込み量の確認
- [ ] アラートの確認

### 週次確認項目
- [ ] パフォーマンスメトリクスの確認
- [ ] バックアップ状況の確認
- [ ] セキュリティログの確認

### 月次確認項目
- [ ] コスト分析
- [ ] パフォーマンス最適化の検討
- [ ] バックアップ・リストアテスト

## まとめ

この手順書に従って、Azure Cosmos DB NoSQL APIが正常にセットアップされ、サンプルデータがインポートされました。

### 作成されたリソース
- Cosmos DBアカウント: cosmos-factory-monitoring
- データベース: FactoryMonitoringDB
- コンテナ: SensorData, RealTimeAlerts, EventLogs
- Log Analytics ワークスペース: law-factory-monitoring

### 次のステップ
1. アプリケーションの開発
2. データ収集パイプラインの構築
3. 監視とアラートの詳細設定
4. 運用体制の構築

---

**注意事項**:
- この手順書は学習・検証目的です
- 本番環境では追加のセキュリティ設定が必要です
- 使用後は不要なリソースを削除してコストを抑制してください