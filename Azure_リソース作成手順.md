# Azure リソース作成手順

## 概要

工場設備管理アプリで使用するAzureリソースを作成する手順を説明します。この手順は Azure の初心者向けに詳細なステップで構成されています。

## 前提条件

### 必要なもの
- Azure アカウント（無料アカウントでも可能）
- Azure CLI がインストールされたPC
- インターネット接続

### Azure CLI のインストール
Azure CLI が未インストールの場合は、以下のコマンドでインストールしてください：

**Windows の場合:**
```bash
# PowerShell を管理者として実行
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
```

**macOS の場合:**
```bash
# Homebrew を使用
brew update && brew install azure-cli
```

**Linux (Ubuntu) の場合:**
```bash
# apt を使用
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## ステップ 1: Azure へのログイン

```bash
# Azure にログイン
az login
```

**実行結果の確認:**
- ブラウザが開き、Azureのログイン画面が表示されます
- ログイン後、使用可能なサブスクリプション一覧が表示されます
- ログインが成功したことを確認してください

## ステップ 2: リソースグループの作成

```bash
# リソースグループの作成
az group create \
    --name rg-factory-equipment-demo \
    --location japaneast \
    --tags project=factory-equipment-management environment=demo
```

**パラメータ説明:**
- `--name`: リソースグループ名（rg-factory-equipment-demo）
- `--location`: デプロイリージョン（東日本リージョン）
- `--tags`: リソース管理用のタグ

**実行結果の確認:**
```bash
# リソースグループが作成されたことを確認
az group show --name rg-factory-equipment-demo
```

## ステップ 3: Azure SQL Database の作成

### 3.1 SQL Server の作成

```bash
# SQL Server の作成
az sql server create \
    --name sql-factory-equipment-demo-$(date +%s) \
    --resource-group rg-factory-equipment-demo \
    --location japaneast \
    --admin-user sqladmin \
    --admin-password P@ssw0rd123! \
    --enable-public-network true
```

**注意:**
- パスワードは実際の環境では、より強固なものを使用してください
- サーバー名はグローバルに一意である必要があります

### 3.2 SQL Database の作成

```bash
# データベースの作成
az sql db create \
    --resource-group rg-factory-equipment-demo \
    --server sql-factory-equipment-demo-$(date +%s) \
    --name FactoryEquipmentDB \
    --service-objective Basic \
    --backup-storage-redundancy Local
```

### 3.3 ファイアウォール設定

```bash
# Azure サービスへのアクセスを許可
az sql server firewall-rule create \
    --resource-group rg-factory-equipment-demo \
    --server sql-factory-equipment-demo-$(date +%s) \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# 開発用に現在のIPアドレスを許可
az sql server firewall-rule create \
    --resource-group rg-factory-equipment-demo \
    --server sql-factory-equipment-demo-$(date +%s) \
    --name AllowCurrentIP \
    --start-ip-address $(curl -s https://ipinfo.io/ip) \
    --end-ip-address $(curl -s https://ipinfo.io/ip)
```

## ステップ 4: Azure Cosmos DB の作成

```bash
# Cosmos DB アカウントの作成
az cosmosdb create \
    --name cosmos-factory-equipment-demo-$(date +%s) \
    --resource-group rg-factory-equipment-demo \
    --location japaneast \
    --default-consistency-level Session \
    --enable-free-tier true
```

### 4.1 データベースの作成

```bash
# Cosmos DB データベースの作成
az cosmosdb sql database create \
    --account-name cosmos-factory-equipment-demo-$(date +%s) \
    --resource-group rg-factory-equipment-demo \
    --name EquipmentData
```

### 4.2 コンテナーの作成

```bash
# センサーデータ用コンテナーの作成
az cosmosdb sql container create \
    --account-name cosmos-factory-equipment-demo-$(date +%s) \
    --resource-group rg-factory-equipment-demo \
    --database-name EquipmentData \
    --name SensorData \
    --partition-key-path "/equipmentId" \
    --throughput 400
```

## ステップ 5: Azure Functions の作成

### 5.1 ストレージアカウントの作成

```bash
# Functions 用ストレージアカウントの作成
az storage account create \
    --name stfactoryequipment$(date +%s | tail -c 8) \
    --resource-group rg-factory-equipment-demo \
    --location japaneast \
    --sku Standard_LRS \
    --kind StorageV2
```

### 5.2 Function App の作成

```bash
# Function App の作成
az functionapp create \
    --name func-factory-equipment-demo-$(date +%s) \
    --resource-group rg-factory-equipment-demo \
    --storage-account stfactoryequipment$(date +%s | tail -c 8) \
    --runtime python \
    --runtime-version 3.9 \
    --os-type Linux \
    --consumption-plan-location japaneast
```

## ステップ 6: Azure IoT Hub の作成

```bash
# IoT Hub の作成
az iot hub create \
    --name iothub-factory-equipment-demo-$(date +%s) \
    --resource-group rg-factory-equipment-demo \
    --location japaneast \
    --sku F1 \
    --partition-count 2
```

**注意:** F1 SKU は無料ティアですが、1つのサブスクリプションにつき1つまでです。

## ステップ 7: リソース作成の確認

```bash
# 作成されたリソースの一覧を確認
az resource list \
    --resource-group rg-factory-equipment-demo \
    --output table
```

## ステップ 8: 接続情報の取得

### 8.1 SQL Database 接続文字列

```bash
# SQL Database の接続文字列を取得
az sql db show-connection-string \
    --server sql-factory-equipment-demo-$(date +%s) \
    --name FactoryEquipmentDB \
    --client ado.net
```

### 8.2 Cosmos DB 接続文字列

```bash
# Cosmos DB の接続文字列を取得
az cosmosdb keys list \
    --name cosmos-factory-equipment-demo-$(date +%s) \
    --resource-group rg-factory-equipment-demo \
    --type connection-strings
```

### 8.3 IoT Hub 接続文字列

```bash
# IoT Hub の接続文字列を取得
az iot hub connection-string show \
    --hub-name iothub-factory-equipment-demo-$(date +%s) \
    --policy-name iothubowner
```

## トラブルシューティング

### よくあるエラーと対処法

1. **リソース名の重複エラー**
   - エラー: "already exists" 
   - 対処: リソース名にタイムスタンプを追加しているため、通常は発生しません

2. **権限エラー**
   - エラー: "Insufficient privileges"
   - 対処: Azure アカウントに適切な権限があることを確認

3. **リージョンエラー**
   - エラー: "not available in region"
   - 対処: japanwest リージョンに変更して再実行

### リソースの削除

テスト後にリソースを削除する場合：

```bash
# リソースグループごと削除
az group delete \
    --name rg-factory-equipment-demo \
    --yes \
    --no-wait
```

## 次のステップ

リソースの作成が完了したら、次の手順に進んでください：
- [開発環境セットアップ手順](./開発環境セットアップ手順.md)

## 注意事項

- Azure リソースの利用には料金が発生する可能性があります
- 無料利用枠を超えないよう注意してください
- 不要になったリソースは削除することをお勧めします