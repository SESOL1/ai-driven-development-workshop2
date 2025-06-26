-- ================================================
-- 工場設備監視システム - サンプルデータ挿入スクリプト  
-- Azure SQL Database v12 対応
-- 作成日: 2024年12月19日
-- ================================================

-- ================================================
-- 1. ユーザーデータ挿入
-- ================================================
INSERT INTO [User] (username, email, password_hash, role, full_name, department, phone, status) VALUES
('admin01', 'admin@factory.co.jp', 'hash123456789', 'admin', '管理者 太郎', 'システム管理部', '03-1234-5678', 'active'),
('manager01', 'manager@factory.co.jp', 'hash987654321', 'manager', '工場長 次郎', '工場管理部', '03-2345-6789', 'active'),
('tech01', 'tech01@factory.co.jp', 'hash111222333', 'technician', '技術者 三郎', '保守技術部', '03-3456-7890', 'active'),
('tech02', 'tech02@factory.co.jp', 'hash444555666', 'technician', '技術者 四郎', '保守技術部', '03-4567-8901', 'active'),
('operator01', 'op01@factory.co.jp', 'hash777888999', 'operator', '作業員 五郎', '製造部', '03-5678-9012', 'active'),
('operator02', 'op02@factory.co.jp', 'hash000111222', 'operator', '作業員 六郎', '製造部', '03-6789-0123', 'active');

-- ================================================
-- 2. 設備マスターデータ挿入
-- ================================================
INSERT INTO Equipment (equipment_name, equipment_type, location, manufacturer, model, installation_date, status) VALUES
('生産ライン1号機', '生産設備', '第1工場A区域', '日本製造株式会社', 'PL-2024A', '2024-01-15', 'active'),
('生産ライン2号機', '生産設備', '第1工場B区域', '日本製造株式会社', 'PL-2024B', '2024-02-01', 'active'),
('搬送コンベア1', '搬送設備', '第1工場中央通路', '搬送システム工業', 'CV-3000X', '2023-12-10', 'active'),
('搬送コンベア2', '搬送設備', '第1工場東側通路', '搬送システム工業', 'CV-3000Y', '2023-12-15', 'active'),
('冷却ポンプ1', '補助設備', '第1工場冷却室', '流体機器製作所', 'CP-500A', '2023-11-20', 'active'),
('冷却ポンプ2', '補助設備', '第1工場冷却室', '流体機器製作所', 'CP-500B', '2023-11-25', 'maintenance'),
('エアコンプレッサ1', '補助設備', '第1工場電気室', '圧縮機メーカー', 'AC-1000Z', '2024-03-01', 'active'),
('品質検査装置1', '検査設備', '第1工場検査区域', '精密測定機器', 'QC-2024', '2024-02-15', 'active'),
('包装機械1', '包装設備', '第1工場包装区域', 'パッケージ機械', 'PK-AUTO1', '2024-01-30', 'active'),
('廃水処理装置', '環境設備', '第1工場処理施設', '環境技術エンジニアリング', 'WT-PRO500', '2023-10-01', 'active');

-- ================================================
-- 3. センサーマスターデータ挿入
-- ================================================
INSERT INTO Sensor (equipment_id, sensor_type, sensor_name, unit, threshold_min, threshold_max, status) VALUES
-- 生産ライン1号機のセンサー
(1, '温度', '生産ライン1号機_温度センサー', '℃', 10.0, 80.0, 'active'),
(1, '振動', '生産ライン1号機_振動センサー', 'mm/s', 0.1, 15.0, 'active'),
(1, '電流', '生産ライン1号機_電流センサー', 'A', 5.0, 50.0, 'active'),
(1, '稼働状態', '生産ライン1号機_稼働センサー', 'boolean', 0, 1, 'active'),

-- 生産ライン2号機のセンサー
(2, '温度', '生産ライン2号機_温度センサー', '℃', 10.0, 80.0, 'active'),
(2, '振動', '生産ライン2号機_振動センサー', 'mm/s', 0.1, 15.0, 'active'),
(2, '電流', '生産ライン2号機_電流センサー', 'A', 5.0, 50.0, 'active'),
(2, '稼働状態', '生産ライン2号機_稼働センサー', 'boolean', 0, 1, 'active'),

-- 搬送コンベア1のセンサー
(3, '速度', '搬送コンベア1_速度センサー', 'm/min', 1.0, 30.0, 'active'),
(3, '電流', '搬送コンベア1_電流センサー', 'A', 2.0, 25.0, 'active'),
(3, '稼働状態', '搬送コンベア1_稼働センサー', 'boolean', 0, 1, 'active'),

-- 搬送コンベア2のセンサー
(4, '速度', '搬送コンベア2_速度センサー', 'm/min', 1.0, 30.0, 'active'),
(4, '電流', '搬送コンベア2_電流センサー', 'A', 2.0, 25.0, 'active'),
(4, '稼働状態', '搬送コンベア2_稼働センサー', 'boolean', 0, 1, 'active'),

-- 冷却ポンプ1のセンサー
(5, '温度', '冷却ポンプ1_温度センサー', '℃', 5.0, 40.0, 'active'),
(5, '圧力', '冷却ポンプ1_圧力センサー', 'MPa', 0.1, 0.8, 'active'),
(5, '流量', '冷却ポンプ1_流量センサー', 'L/min', 10.0, 100.0, 'active'),
(5, '振動', '冷却ポンプ1_振動センサー', 'mm/s', 0.1, 10.0, 'active'),

-- 冷却ポンプ2のセンサー
(6, '温度', '冷却ポンプ2_温度センサー', '℃', 5.0, 40.0, 'maintenance'),
(6, '圧力', '冷却ポンプ2_圧力センサー', 'MPa', 0.1, 0.8, 'maintenance'),
(6, '流量', '冷却ポンプ2_流量センサー', 'L/min', 10.0, 100.0, 'maintenance'),
(6, '振動', '冷却ポンプ2_振動センサー', 'mm/s', 0.1, 10.0, 'maintenance'),

-- エアコンプレッサ1のセンサー
(7, '圧力', 'エアコンプレッサ1_圧力センサー', 'MPa', 0.5, 1.2, 'active'),
(7, '温度', 'エアコンプレッサ1_温度センサー', '℃', 15.0, 90.0, 'active'),
(7, '電流', 'エアコンプレッサ1_電流センサー', 'A', 8.0, 60.0, 'active'),

-- 品質検査装置1のセンサー
(8, '精度', '品質検査装置1_精度センサー', 'μm', 0.1, 5.0, 'active'),
(8, '電流', '品質検査装置1_電流センサー', 'A', 1.0, 15.0, 'active'),

-- 包装機械1のセンサー
(9, '速度', '包装機械1_速度センサー', 'pcs/min', 50, 300, 'active'),
(9, '電流', '包装機械1_電流センサー', 'A', 3.0, 30.0, 'active'),

-- 廃水処理装置のセンサー
(10, 'pH', '廃水処理装置_pHセンサー', 'pH', 6.0, 8.0, 'active'),
(10, '濁度', '廃水処理装置_濁度センサー', 'NTU', 0, 10.0, 'active'),
(10, '流量', '廃水処理装置_流量センサー', 'L/min', 50.0, 500.0, 'active');

-- ================================================
-- 4. 異常検知ログデータ挿入
-- ================================================
INSERT INTO AnomalyLog (equipment_id, sensor_id, anomaly_type, severity, description, detected_at, status) VALUES
(1, 1, '温度異常', 'medium', '生産ライン1号機の温度が基準値を超過しました', DATEADD(hour, -2, GETUTCDATE()), 'resolved'),
(2, 6, '振動異常', 'high', '生産ライン2号機で異常振動を検知しました', DATEADD(hour, -1, GETUTCDATE()), 'acknowledged'),
(5, 18, '流量低下', 'medium', '冷却ポンプ1の流量が低下しています', DATEADD(minute, -30, GETUTCDATE()), 'open'),
(3, 9, '速度異常', 'low', '搬送コンベア1の速度が若干低下しています', DATEADD(hour, -4, GETUTCDATE()), 'resolved'),
(7, 23, '圧力異常', 'critical', 'エアコンプレッサ1の圧力が危険レベルに達しました', DATEADD(minute, -10, GETUTCDATE()), 'open'),
(10, 30, 'pH異常', 'medium', '廃水処理装置のpH値が基準範囲外です', DATEADD(hour, -6, GETUTCDATE()), 'resolved'),
(9, 27, '速度低下', 'low', '包装機械1の処理速度が低下しています', DATEADD(hour, -3, GETUTCDATE()), 'acknowledged');

-- ================================================
-- 5. アラート管理データ挿入
-- ================================================
INSERT INTO Alert (anomaly_id, alert_type, severity, message, recipient, sent_at, status) VALUES
(1, 'email', 'medium', '【注意】生産ライン1号機で温度異常が発生しました。確認をお願いします。', 'tech01@factory.co.jp', DATEADD(hour, -2, GETUTCDATE()), 'acknowledged'),
(2, 'sms', 'high', '【警告】生産ライン2号機で異常振動を検知。至急確認してください。', '03-3456-7890', DATEADD(hour, -1, GETUTCDATE()), 'acknowledged'),
(3, 'email', 'medium', '【注意】冷却ポンプ1の流量低下を検知しました。', 'tech02@factory.co.jp', DATEADD(minute, -30, GETUTCDATE()), 'sent'),
(5, 'sms', 'critical', '【緊急】エアコンプレッサ1で圧力異常！即座に対応が必要です。', '03-3456-7890', DATEADD(minute, -10, GETUTCDATE()), 'sent'),
(5, 'email', 'critical', '【緊急アラート】エアコンプレッサ1で圧力異常が発生しました。安全のため即座に停止してください。', 'manager@factory.co.jp', DATEADD(minute, -10, GETUTCDATE()), 'sent'),
(7, 'email', 'low', '【情報】包装機械1の処理速度が若干低下しています。', 'operator01@factory.co.jp', DATEADD(hour, -3, GETUTCDATE()), 'acknowledged');

-- ================================================
-- 6. メンテナンス予定データ挿入
-- ================================================
INSERT INTO MaintenanceSchedule (equipment_id, maintenance_type, description, scheduled_date, estimated_duration, assigned_technician, status) VALUES
(1, '定期点検', '生産ライン1号機の月次定期点検', DATEADD(day, 1, GETDATE()), 240, 3, 'scheduled'),
(2, '清掃', '生産ライン2号機の清掃とフィルター交換', DATEADD(day, 2, GETDATE()), 120, 4, 'scheduled'),
(6, '修理', '冷却ポンプ2のシール交換とオーバーホール', GETDATE(), 480, 3, 'in_progress'),
(3, '定期点検', '搬送コンベア1のベルト点検と調整', DATEADD(day, 3, GETDATE()), 180, 4, 'scheduled'),
(7, '緊急修理', 'エアコンプレッサ1の圧力調整弁交換', GETDATE(), 300, 3, 'scheduled'),
(8, '校正', '品質検査装置1の精度校正作業', DATEADD(day, 5, GETDATE()), 150, 4, 'scheduled'),
(10, '定期点検', '廃水処理装置の月次点検とセンサー清掃', DATEADD(day, 7, GETDATE()), 200, 3, 'scheduled');

-- ================================================
-- 7. メンテナンス実績データ挿入
-- ================================================
INSERT INTO MaintenanceHistory (schedule_id, equipment_id, maintenance_type, description, start_time, end_time, technician, result, notes, cost) VALUES
(NULL, 1, '定期点検', '生産ライン1号機の前月定期点検', DATEADD(day, -30, GETDATE()), DATEADD(day, -30, DATEADD(hour, 4, GETDATE())), 3, 'completed', '正常動作確認。次回点検時期は来月予定。', 15000.00),
(NULL, 2, '部品交換', '生産ライン2号機のベアリング交換', DATEADD(day, -15, GETDATE()), DATEADD(day, -15, DATEADD(hour, 3, GETDATE())), 4, 'completed', 'ベアリング交換完了。振動値が正常範囲に復帰。', 25000.00),
(NULL, 5, '清掃', '冷却ポンプ1のフィルター清掃', DATEADD(day, -10, GETDATE()), DATEADD(day, -10, DATEADD(minute, 90, GETDATE())), 3, 'completed', 'フィルター清掃により流量が改善。', 3000.00),
(NULL, 9, '調整', '包装機械1の速度調整', DATEADD(day, -7, GETDATE()), DATEADD(day, -7, DATEADD(hour, 1, GETDATE())), 4, 'completed', '包装速度を最適化。効率が10%向上。', 5000.00),
(NULL, 10, '部品交換', '廃水処理装置のpHセンサー交換', DATEADD(day, -20, GETDATE()), DATEADD(day, -20, DATEADD(hour, 2, GETDATE())), 3, 'completed', 'pHセンサー交換により測定精度が向上。', 18000.00);

-- ================================================
-- 8. ダッシュボード設定データ挿入
-- ================================================
INSERT INTO DashboardConfig (user_id, dashboard_name, widget_config, filter_config) VALUES
(2, '工場長ダッシュボード', 
'[{"type":"equipment_status","position":{"x":0,"y":0,"w":6,"h":4},"title":"設備稼働状況"},{"type":"alert_summary","position":{"x":6,"y":0,"w":6,"h":4},"title":"アラート状況"},{"type":"efficiency_chart","position":{"x":0,"y":4,"w":12,"h":6},"title":"生産効率推移"}]',
'{"equipment_types":["生産設備","搬送設備"],"time_range":"24h","severity_filter":["medium","high","critical"]}'),

(3, '技術者ダッシュボード',
'[{"type":"maintenance_schedule","position":{"x":0,"y":0,"w":8,"h":6},"title":"メンテナンス予定"},{"type":"anomaly_list","position":{"x":8,"y":0,"w":4,"h":6},"title":"異常一覧"},{"type":"sensor_data","position":{"x":0,"y":6,"w":12,"h":6},"title":"センサーデータ"}]',
'{"assigned_to_me":true,"status_filter":["scheduled","in_progress"],"equipment_filter":[1,2,5,6,7]}'),

(1, 'システム管理ダッシュボード',
'[{"type":"system_health","position":{"x":0,"y":0,"w":6,"h":4},"title":"システム状態"},{"type":"user_activity","position":{"x":6,"y":0,"w":6,"h":4},"title":"ユーザー活動"},{"type":"data_quality","position":{"x":0,"y":4,"w":12,"h":6},"title":"データ品質"}]',
'{"show_all_users":true,"time_range":"7d","include_system_logs":true}');

-- ================================================
-- 更新日時の設定（作成日時と同じに設定）
-- ================================================
UPDATE [User] SET last_login = DATEADD(hour, -FLOOR(RAND() * 24), GETUTCDATE()) WHERE user_id IN (2,3,4,5,6);

UPDATE Equipment SET updated_at = created_at;
UPDATE Sensor SET updated_at = created_at;
UPDATE MaintenanceSchedule SET updated_at = created_at;
UPDATE DashboardConfig SET updated_at = created_at;

-- 解決済みの異常ログの解決日時を設定
UPDATE AnomalyLog 
SET resolved_at = DATEADD(hour, 1, detected_at), resolved_by = 3 
WHERE status = 'resolved';

-- 確認済みのアラートの確認日時を設定  
UPDATE Alert 
SET acknowledged_at = DATEADD(minute, 30, sent_at), acknowledged_by = 3 
WHERE status = 'acknowledged';

PRINT 'サンプルデータの挿入が完了しました。';
PRINT '挿入されたデータ:';
PRINT '- ユーザー: 6件';
PRINT '- 設備: 10件'; 
PRINT '- センサー: 30件';
PRINT '- 異常ログ: 7件';
PRINT '- アラート: 6件';
PRINT '- メンテナンス予定: 7件';
PRINT '- メンテナンス実績: 5件';
PRINT '- ダッシュボード設定: 3件';