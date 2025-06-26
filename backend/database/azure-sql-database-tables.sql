-- ================================================
-- 工場設備監視システム - Azure SQL Database テーブル作成スクリプト
-- Azure SQL Database v12 対応
-- 作成日: 2024年12月19日
-- ================================================

-- データベース作成 (必要に応じて実行)
-- CREATE DATABASE FactoryMonitoringSystem;
-- GO

-- データーベースの使用
-- USE FactoryMonitoringSystem;
-- GO

-- ================================================
-- 1. ユーザー管理テーブル
-- ================================================
CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    role NVARCHAR(20) NOT NULL CHECK (role IN ('admin', 'manager', 'technician', 'operator')),
    full_name NVARCHAR(100) NOT NULL,
    department NVARCHAR(50),
    phone NVARCHAR(20),
    last_login DATETIME2,
    status NVARCHAR(10) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- ================================================
-- 2. 設備マスターテーブル  
-- ================================================
CREATE TABLE Equipment (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_name NVARCHAR(100) NOT NULL,
    equipment_type NVARCHAR(50) NOT NULL,
    location NVARCHAR(100) NOT NULL,
    manufacturer NVARCHAR(100),
    model NVARCHAR(100),
    installation_date DATE,
    status NVARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance', 'decommissioned')),
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- ================================================
-- 3. センサーマスターテーブル
-- ================================================
CREATE TABLE Sensor (
    sensor_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    sensor_type NVARCHAR(50) NOT NULL,
    sensor_name NVARCHAR(100) NOT NULL,
    unit NVARCHAR(20) NOT NULL,
    threshold_min FLOAT,
    threshold_max FLOAT,
    status NVARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);

-- ================================================
-- 4. 異常検知ログテーブル
-- ================================================
CREATE TABLE AnomalyLog (
    anomaly_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    sensor_id INT,
    anomaly_type NVARCHAR(50) NOT NULL,
    severity NVARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    description NVARCHAR(500),
    detected_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    resolved_at DATETIME2,
    resolved_by INT,
    status NVARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'acknowledged', 'resolved', 'closed')),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    FOREIGN KEY (sensor_id) REFERENCES Sensor(sensor_id),
    FOREIGN KEY (resolved_by) REFERENCES [User](user_id)
);

-- ================================================
-- 5. アラート管理テーブル
-- ================================================
CREATE TABLE Alert (
    alert_id INT IDENTITY(1,1) PRIMARY KEY,
    anomaly_id INT NOT NULL,
    alert_type NVARCHAR(50) NOT NULL,
    severity NVARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    message NVARCHAR(500) NOT NULL,
    recipient NVARCHAR(200) NOT NULL,
    sent_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    status NVARCHAR(20) NOT NULL DEFAULT 'sent' CHECK (status IN ('pending', 'sent', 'failed', 'acknowledged')),
    acknowledged_at DATETIME2,
    acknowledged_by INT,
    FOREIGN KEY (anomaly_id) REFERENCES AnomalyLog(anomaly_id),
    FOREIGN KEY (acknowledged_by) REFERENCES [User](user_id)
);

-- ================================================
-- 6. メンテナンス予定テーブル
-- ================================================
CREATE TABLE MaintenanceSchedule (
    schedule_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    maintenance_type NVARCHAR(50) NOT NULL,
    description NVARCHAR(500),
    scheduled_date DATETIME2 NOT NULL,
    estimated_duration INT, -- 分単位
    assigned_technician INT,
    status NVARCHAR(20) NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'rescheduled')),
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    FOREIGN KEY (assigned_technician) REFERENCES [User](user_id)
);

-- ================================================
-- 7. メンテナンス実績テーブル
-- ================================================
CREATE TABLE MaintenanceHistory (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    schedule_id INT,
    equipment_id INT NOT NULL,
    maintenance_type NVARCHAR(50) NOT NULL,
    description NVARCHAR(500),
    start_time DATETIME2 NOT NULL,
    end_time DATETIME2,
    technician INT NOT NULL,
    result NVARCHAR(50) NOT NULL CHECK (result IN ('completed', 'partially_completed', 'failed', 'cancelled')),
    notes NTEXT,
    cost DECIMAL(12,2),
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (schedule_id) REFERENCES MaintenanceSchedule(schedule_id),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id),
    FOREIGN KEY (technician) REFERENCES [User](user_id)
);

-- ================================================
-- 8. ダッシュボード設定テーブル  
-- ================================================
CREATE TABLE DashboardConfig (
    config_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    dashboard_name NVARCHAR(100) NOT NULL,
    widget_config NTEXT, -- JSON形式でウィジェット設定を保存
    filter_config NTEXT, -- JSON形式でフィルター設定を保存
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (user_id) REFERENCES [User](user_id)
);

-- ================================================
-- インデックス作成
-- ================================================

-- Equipment テーブル
CREATE INDEX IX_Equipment_Type ON Equipment(equipment_type);
CREATE INDEX IX_Equipment_Location ON Equipment(location);
CREATE INDEX IX_Equipment_Status ON Equipment(status);

-- Sensor テーブル  
CREATE INDEX IX_Sensor_Equipment ON Sensor(equipment_id);
CREATE INDEX IX_Sensor_Type ON Sensor(sensor_type);

-- AnomalyLog テーブル
CREATE INDEX IX_AnomalyLog_Equipment ON AnomalyLog(equipment_id);
CREATE INDEX IX_AnomalyLog_Detected ON AnomalyLog(detected_at);
CREATE INDEX IX_AnomalyLog_Severity ON AnomalyLog(severity);
CREATE INDEX IX_AnomalyLog_Status ON AnomalyLog(status);

-- Alert テーブル
CREATE INDEX IX_Alert_Anomaly ON Alert(anomaly_id);
CREATE INDEX IX_Alert_Sent ON Alert(sent_at);
CREATE INDEX IX_Alert_Status ON Alert(status);

-- MaintenanceSchedule テーブル
CREATE INDEX IX_MaintenanceSchedule_Equipment ON MaintenanceSchedule(equipment_id);
CREATE INDEX IX_MaintenanceSchedule_Date ON MaintenanceSchedule(scheduled_date);
CREATE INDEX IX_MaintenanceSchedule_Status ON MaintenanceSchedule(status);

-- MaintenanceHistory テーブル
CREATE INDEX IX_MaintenanceHistory_Equipment ON MaintenanceHistory(equipment_id);
CREATE INDEX IX_MaintenanceHistory_Start ON MaintenanceHistory(start_time);
CREATE INDEX IX_MaintenanceHistory_Technician ON MaintenanceHistory(technician);

-- DashboardConfig テーブル
CREATE INDEX IX_DashboardConfig_User ON DashboardConfig(user_id);

-- ================================================
-- トリガー作成（更新日時の自動更新）
-- ================================================

-- User テーブル更新トリガー
CREATE TRIGGER TR_User_UpdateTimestamp
ON [User]
AFTER UPDATE
AS
BEGIN
    UPDATE [User]
    SET updated_at = GETUTCDATE()
    FROM [User] u
    INNER JOIN inserted i ON u.user_id = i.user_id;
END;
GO

-- Equipment テーブル更新トリガー
CREATE TRIGGER TR_Equipment_UpdateTimestamp
ON Equipment
AFTER UPDATE
AS
BEGIN
    UPDATE Equipment
    SET updated_at = GETUTCDATE()
    FROM Equipment e
    INNER JOIN inserted i ON e.equipment_id = i.equipment_id;
END;
GO

-- Sensor テーブル更新トリガー
CREATE TRIGGER TR_Sensor_UpdateTimestamp
ON Sensor
AFTER UPDATE
AS
BEGIN
    UPDATE Sensor
    SET updated_at = GETUTCDATE()
    FROM Sensor s
    INNER JOIN inserted i ON s.sensor_id = i.sensor_id;
END;
GO

-- MaintenanceSchedule テーブル更新トリガー
CREATE TRIGGER TR_MaintenanceSchedule_UpdateTimestamp
ON MaintenanceSchedule
AFTER UPDATE
AS
BEGIN
    UPDATE MaintenanceSchedule
    SET updated_at = GETUTCDATE()
    FROM MaintenanceSchedule ms
    INNER JOIN inserted i ON ms.schedule_id = i.schedule_id;
END;
GO

-- DashboardConfig テーブル更新トリガー
CREATE TRIGGER TR_DashboardConfig_UpdateTimestamp
ON DashboardConfig
AFTER UPDATE
AS
BEGIN
    UPDATE DashboardConfig
    SET updated_at = GETUTCDATE()
    FROM DashboardConfig dc
    INNER JOIN inserted i ON dc.config_id = i.config_id;
END;
GO

-- ================================================
-- ビュー作成（よく使用されるクエリの最適化）
-- ================================================

-- 設備とセンサーの結合ビュー
CREATE VIEW V_EquipmentSensor AS
SELECT 
    e.equipment_id,
    e.equipment_name,
    e.equipment_type,
    e.location,
    e.status as equipment_status,
    s.sensor_id,
    s.sensor_name,
    s.sensor_type,
    s.unit,
    s.threshold_min,
    s.threshold_max,
    s.status as sensor_status
FROM Equipment e
LEFT JOIN Sensor s ON e.equipment_id = s.equipment_id;
GO

-- アクティブな異常ログビュー
CREATE VIEW V_ActiveAnomalies AS
SELECT 
    al.anomaly_id,
    e.equipment_name,
    e.location,
    s.sensor_name,
    al.anomaly_type,
    al.severity,
    al.description,
    al.detected_at,
    DATEDIFF(minute, al.detected_at, GETUTCDATE()) as minutes_since_detected
FROM AnomalyLog al
INNER JOIN Equipment e ON al.equipment_id = e.equipment_id
LEFT JOIN Sensor s ON al.sensor_id = s.sensor_id
WHERE al.status IN ('open', 'acknowledged');
GO

-- 今日のメンテナンス予定ビュー
CREATE VIEW V_TodayMaintenance AS
SELECT 
    ms.schedule_id,
    e.equipment_name,
    e.location,
    ms.maintenance_type,
    ms.description,
    ms.scheduled_date,
    ms.estimated_duration,
    u.full_name as technician_name,
    ms.status
FROM MaintenanceSchedule ms
INNER JOIN Equipment e ON ms.equipment_id = e.equipment_id
LEFT JOIN [User] u ON ms.assigned_technician = u.user_id
WHERE CAST(ms.scheduled_date AS DATE) = CAST(GETDATE() AS DATE);
GO

PRINT 'Azure SQL Database テーブル作成が完了しました。';