#!/usr/bin/env python3
"""
Azure Cosmos DB データインポートユーティリティ
工場設備監視システム用サンプルデータをCosmos DBにインポートします。

使用方法:
    python import_cosmosdb_data.py --endpoint <endpoint> --key <key> --database <database>

必要なライブラリ:
    pip install azure-cosmos python-dotenv
"""

import json
import argparse
import os
import sys
from datetime import datetime, timedelta
from azure.cosmos import CosmosClient, PartitionKey
from azure.cosmos.exceptions import CosmosResourceExistsError, CosmosHttpResponseError

class CosmosDBImporter:
    def __init__(self, endpoint, key, database_name):
        """
        Cosmos DB インポーターを初期化
        
        Args:
            endpoint (str): Cosmos DB エンドポイント
            key (str): Cosmos DB プライマリキー
            database_name (str): データベース名
        """
        self.client = CosmosClient(endpoint, key)
        self.database_name = database_name
        
        try:
            self.database = self.client.get_database_client(database_name)
            print(f"データベース '{database_name}' に接続しました。")
        except CosmosHttpResponseError as e:
            print(f"データベースへの接続に失敗しました: {e}")
            sys.exit(1)

    def import_sensor_data(self, file_path="sensor-data-sample.json"):
        """
        センサーデータをSensorDataコンテナにインポート
        
        Args:
            file_path (str): インポートするJSONファイルのパス
        """
        print(f"\n=== センサーデータのインポート開始 ===")
        
        try:
            container = self.database.get_container_client("SensorData")
        except CosmosHttpResponseError:
            print("SensorDataコンテナが見つかりません。先にコンテナを作成してください。")
            return False
        
        return self._import_json_file(container, file_path, "センサーデータ")

    def import_realtime_alerts(self, file_path="realtime-alerts-sample.json"):
        """
        リアルタイムアラートをRealTimeAlertsコンテナにインポート
        
        Args:
            file_path (str): インポートするJSONファイルのパス
        """
        print(f"\n=== リアルタイムアラートのインポート開始 ===")
        
        try:
            container = self.database.get_container_client("RealTimeAlerts")
        except CosmosHttpResponseError:
            print("RealTimeAlertsコンテナが見つかりません。先にコンテナを作成してください。")
            return False
        
        return self._import_json_file(container, file_path, "リアルタイムアラート")

    def _import_json_file(self, container, file_path, data_type):
        """
        JSONファイルを指定されたコンテナにインポート
        
        Args:
            container: Cosmos DB コンテナクライアント
            file_path (str): JSONファイルパス
            data_type (str): データ種別（ログ表示用）
        
        Returns:
            bool: インポート成功可否
        """
        if not os.path.exists(file_path):
            print(f"ファイル '{file_path}' が見つかりません。")
            return False
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if not isinstance(data, list):
                print(f"JSONファイルは配列形式である必要があります。")
                return False
            
            imported_count = 0
            error_count = 0
            
            for item in data:
                try:
                    container.create_item(body=item)
                    imported_count += 1
                    print(f"✓ インポート成功: {item.get('id', 'ID不明')}")
                    
                except CosmosResourceExistsError:
                    print(f"⚠ 既に存在: {item.get('id', 'ID不明')}")
                    
                except CosmosHttpResponseError as e:
                    error_count += 1
                    print(f"✗ インポートエラー: {item.get('id', 'ID不明')} - {str(e)}")
                    
                except Exception as e:
                    error_count += 1
                    print(f"✗ 予期しないエラー: {item.get('id', 'ID不明')} - {str(e)}")
            
            print(f"\n{data_type}のインポート完了:")
            print(f"  - 成功: {imported_count}件")
            print(f"  - エラー: {error_count}件")
            print(f"  - 総件数: {len(data)}件")
            
            return error_count == 0
            
        except json.JSONDecodeError as e:
            print(f"JSONファイルの解析に失敗しました: {str(e)}")
            return False
        except Exception as e:
            print(f"ファイル読み込みエラー: {str(e)}")
            return False

    def generate_time_series_data(self, hours=24, interval_minutes=5):
        """
        時系列センサーデータを生成してインポート
        
        Args:
            hours (int): 生成する時間数
            interval_minutes (int): データ間隔（分）
        """
        print(f"\n=== 時系列データ生成・インポート開始 ===")
        print(f"期間: {hours}時間, 間隔: {interval_minutes}分")
        
        try:
            container = self.database.get_container_client("SensorData")
        except CosmosHttpResponseError:
            print("SensorDataコンテナが見つかりません。")
            return False
        
        import random
        from datetime import datetime, timedelta
        
        # 設備とセンサーの定義
        equipment_sensors = [
            {"equipmentId": 1, "sensorId": 1, "type": "temperature", "unit": "℃", "min": 40, "max": 85, "normal": 55},
            {"equipmentId": 1, "sensorId": 2, "type": "vibration", "unit": "mm/s", "min": 5, "max": 15, "normal": 8},
            {"equipmentId": 2, "sensorId": 5, "type": "temperature", "unit": "℃", "min": 42, "max": 88, "normal": 58},
            {"equipmentId": 2, "sensorId": 6, "type": "vibration", "unit": "mm/s", "min": 6, "max": 16, "normal": 9},
            {"equipmentId": 5, "sensorId": 18, "type": "flow_rate", "unit": "L/min", "min": 60, "max": 95, "normal": 78}
        ]
        
        start_time = datetime.utcnow() - timedelta(hours=hours)
        imported_count = 0
        
        for i in range(0, hours * 60, interval_minutes):
            timestamp = start_time + timedelta(minutes=i)
            
            for sensor in equipment_sensors:
                # 正常値周辺でランダムな値を生成
                base_value = sensor["normal"]
                variation = (sensor["max"] - sensor["min"]) * 0.1
                value = base_value + random.uniform(-variation, variation)
                
                # 状態判定
                if value > sensor["max"] * 0.9:
                    status = "warning"
                elif value > sensor["max"]:
                    status = "critical"
                else:
                    status = "normal"
                
                # データアイテム作成
                item = {
                    "id": f"ts_{sensor['sensorId']}_{int(timestamp.timestamp())}",
                    "sensorId": sensor["sensorId"],
                    "equipmentId": sensor["equipmentId"],
                    "sensorType": sensor["type"],
                    "value": round(value, 2),
                    "unit": sensor["unit"],
                    "timestamp": timestamp.isoformat() + "Z",
                    "status": status,
                    "metadata": {
                        "generated": True,
                        "quality": "good"
                    }
                }
                
                try:
                    container.create_item(body=item)
                    imported_count += 1
                    if imported_count % 50 == 0:
                        print(f"進行状況: {imported_count}件完了...")
                        
                except CosmosResourceExistsError:
                    pass  # 既存データはスキップ
                except Exception as e:
                    print(f"エラー: {item['id']} - {str(e)}")
        
        print(f"時系列データ生成完了: {imported_count}件")
        return True

def main():
    parser = argparse.ArgumentParser(description='Cosmos DB データインポートツール')
    parser.add_argument('--endpoint', required=True, help='Cosmos DB エンドポイント')
    parser.add_argument('--key', required=True, help='Cosmos DB プライマリキー')
    parser.add_argument('--database', default='FactoryMonitoringDB', help='データベース名')
    parser.add_argument('--sensor-data', default='sensor-data-sample.json', help='センサーデータファイル')
    parser.add_argument('--alerts-data', default='realtime-alerts-sample.json', help='アラートデータファイル')
    parser.add_argument('--generate-timeseries', action='store_true', help='時系列データを生成')
    parser.add_argument('--hours', type=int, default=24, help='生成する時系列データの時間数')
    parser.add_argument('--interval', type=int, default=5, help='時系列データの間隔（分）')
    
    args = parser.parse_args()
    
    print("=== Azure Cosmos DB データインポートツール ===")
    print(f"エンドポイント: {args.endpoint}")
    print(f"データベース: {args.database}")
    
    # インポーター初期化
    importer = CosmosDBImporter(args.endpoint, args.key, args.database)
    
    success_count = 0
    total_operations = 0
    
    # センサーデータのインポート
    if os.path.exists(args.sensor_data):
        total_operations += 1
        if importer.import_sensor_data(args.sensor_data):
            success_count += 1
    else:
        print(f"センサーデータファイル '{args.sensor_data}' が見つかりません。")
    
    # アラートデータのインポート
    if os.path.exists(args.alerts_data):
        total_operations += 1
        if importer.import_realtime_alerts(args.alerts_data):
            success_count += 1
    else:
        print(f"アラートデータファイル '{args.alerts_data}' が見つかりません。")
    
    # 時系列データの生成
    if args.generate_timeseries:
        total_operations += 1
        if importer.generate_time_series_data(args.hours, args.interval):
            success_count += 1
    
    # 結果表示
    print(f"\n=== インポート結果 ===")
    print(f"成功: {success_count}/{total_operations}")
    
    if success_count == total_operations:
        print("✓ 全てのインポート操作が成功しました！")
        sys.exit(0)
    else:
        print("⚠ 一部のインポート操作でエラーが発生しました。")
        sys.exit(1)

if __name__ == "__main__":
    main()