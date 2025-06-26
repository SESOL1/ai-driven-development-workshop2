<template>
  <div class="equipment-status">
    <div class="page-header">
      <h2>設備稼働状況</h2>
      <div class="header-controls">
        <button class="btn btn-success" @click="refreshData">
          <span>🔄</span> データ更新
        </button>
        <select v-model="selectedArea" @change="filterByArea" class="area-selector">
          <option value="">全エリア</option>
          <option value="A">エリアA</option>
          <option value="B">エリアB</option>
          <option value="C">エリアC</option>
        </select>
      </div>
    </div>

    <!-- 概要統計 -->
    <div class="status-overview">
      <div class="overview-item">
        <div class="overview-value">{{ filteredEquipment.length }}</div>
        <div class="overview-label">総設備数</div>
      </div>
      <div class="overview-item">
        <div class="overview-value">{{ runningCount }}</div>
        <div class="overview-label">稼働中</div>
      </div>
      <div class="overview-item">
        <div class="overview-value">{{ stoppedCount }}</div>
        <div class="overview-label">停止中</div>
      </div>
      <div class="overview-item">
        <div class="overview-value">{{ alertCount }}</div>
        <div class="overview-label">アラート</div>
      </div>
      <div class="overview-item">
        <div class="overview-value">{{ averageEfficiency }}%</div>
        <div class="overview-label">平均効率</div>
      </div>
    </div>

    <!-- 設備一覧 -->
    <div class="equipment-grid">
      <div v-for="equipment in filteredEquipment" :key="equipment.id" class="equipment-card">
        <div class="equipment-header">
          <h3 class="equipment-name">{{ equipment.name }}</h3>
          <span :class="['status-badge', `status-${equipment.status}`]">
            {{ getStatusText(equipment.status) }}
          </span>
        </div>
        
        <div class="equipment-info">
          <div class="info-row">
            <span class="info-label">場所:</span>
            <span class="info-value">{{ equipment.location }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">稼働時間:</span>
            <span class="info-value">{{ equipment.operatingHours }}h</span>
          </div>
          <div class="info-row">
            <span class="info-label">効率:</span>
            <span class="info-value">{{ equipment.efficiency }}%</span>
          </div>
          <div class="info-row">
            <span class="info-label">最終更新:</span>
            <span class="info-value">{{ formatTime(equipment.lastUpdate) }}</span>
          </div>
        </div>

        <!-- センサーデータ -->
        <div class="sensor-data">
          <h4>センサーデータ</h4>
          <div class="sensor-grid">
            <div v-for="sensor in equipment.sensors" :key="sensor.type" class="sensor-item">
              <div class="sensor-type">{{ sensor.name }}</div>
              <div class="sensor-value" :class="{ 'warning': sensor.isWarning, 'error': sensor.isError }">
                {{ sensor.value }}{{ sensor.unit }}
              </div>
              <div class="sensor-status">
                <span :class="['sensor-indicator', sensor.isError ? 'status-error' : sensor.isWarning ? 'status-warning' : 'status-normal']"></span>
                {{ sensor.isError ? '異常' : sensor.isWarning ? '注意' : '正常' }}
              </div>
            </div>
          </div>
        </div>

        <!-- 最近のアラート -->
        <div v-if="equipment.recentAlerts.length > 0" class="recent-alerts">
          <h4>最近のアラート</h4>
          <div class="alert-list">
            <div v-for="alert in equipment.recentAlerts.slice(0, 2)" :key="alert.id" class="alert-item-mini">
              <span :class="['status-indicator', `status-${alert.severity}`]"></span>
              <div class="alert-text">{{ alert.message }}</div>
              <div class="alert-time">{{ formatTime(alert.timestamp) }}</div>
            </div>
          </div>
        </div>

        <!-- アクションボタン -->
        <div class="equipment-actions">
          <button class="btn btn-primary btn-sm" @click="showDetails(equipment)">詳細表示</button>
          <button v-if="equipment.status === 'error'" class="btn btn-warning btn-sm" @click="acknowledgeAlert(equipment)">
            アラート確認
          </button>
        </div>
      </div>
    </div>

    <!-- 詳細モーダル -->
    <div v-if="selectedEquipment" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>{{ selectedEquipment.name }} - 詳細情報</h3>
          <button class="modal-close" @click="closeModal">&times;</button>
        </div>
        <div class="modal-body">
          <div class="detail-section">
            <h4>基本情報</h4>
            <table class="detail-table">
              <tbody>
                <tr><td>設備ID:</td><td>{{ selectedEquipment.id }}</td></tr>
                <tr><td>設備名:</td><td>{{ selectedEquipment.name }}</td></tr>
                <tr><td>設備タイプ:</td><td>{{ selectedEquipment.type }}</td></tr>
                <tr><td>設置場所:</td><td>{{ selectedEquipment.location }}</td></tr>
                <tr><td>メーカー:</td><td>{{ selectedEquipment.manufacturer }}</td></tr>
                <tr><td>モデル:</td><td>{{ selectedEquipment.model }}</td></tr>
              </tbody>
            </table>
          </div>
          
          <div class="detail-section">
            <h4>運転データ</h4>
            <table class="detail-table">
              <tbody>
                <tr><td>稼働状態:</td><td>{{ getStatusText(selectedEquipment.status) }}</td></tr>
                <tr><td>今日の稼働時間:</td><td>{{ selectedEquipment.operatingHours }}時間</td></tr>
                <tr><td>稼働効率:</td><td>{{ selectedEquipment.efficiency }}%</td></tr>
                <tr><td>総稼働時間:</td><td>{{ selectedEquipment.totalOperatingHours }}時間</td></tr>
                <tr><td>最終メンテナンス:</td><td>{{ selectedEquipment.lastMaintenance }}</td></tr>
              </tbody>
            </table>
          </div>
          
          <div class="detail-section">
            <h4>センサーデータ詳細</h4>
            <div class="sensor-detail-grid">
              <div v-for="sensor in selectedEquipment.sensors" :key="sensor.type" class="sensor-detail-item">
                <h5>{{ sensor.name }}</h5>
                <div class="sensor-detail-value">{{ sensor.value }}{{ sensor.unit }}</div>
                <div class="sensor-detail-range">
                  正常範囲: {{ sensor.minValue }}{{ sensor.unit }} ～ {{ sensor.maxValue }}{{ sensor.unit }}
                </div>
                <div class="sensor-history">過去24時間の推移: {{ sensor.trend }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EquipmentStatus',
  data() {
    return {
      selectedArea: '',
      selectedEquipment: null,
      equipmentList: [
        {
          id: 'EQ001',
          name: 'プレス機 #1',
          type: 'プレス機',
          location: 'エリアA-1',
          area: 'A',
          status: 'running',
          operatingHours: 7.5,
          totalOperatingHours: 15420,
          efficiency: 92.5,
          manufacturer: 'YAMADA製作所',
          model: 'YP-3000',
          lastUpdate: new Date(Date.now() - 1000 * 60 * 2),
          lastMaintenance: '2024-12-10',
          sensors: [
            {
              type: 'temperature',
              name: '温度',
              value: 45.2,
              unit: '℃',
              minValue: 20,
              maxValue: 60,
              isWarning: false,
              isError: false,
              trend: '安定'
            },
            {
              type: 'vibration',
              name: '振動',
              value: 0.8,
              unit: 'mm/s',
              minValue: 0,
              maxValue: 2.0,
              isWarning: false,
              isError: false,
              trend: '安定'
            },
            {
              type: 'current',
              name: '電流',
              value: 15.2,
              unit: 'A',
              minValue: 5,
              maxValue: 20,
              isWarning: false,
              isError: false,
              trend: '安定'
            }
          ],
          recentAlerts: []
        },
        {
          id: 'EQ002',
          name: 'プレス機 #2',
          type: 'プレス機',
          location: 'エリアA-2',
          area: 'A',
          status: 'warning',
          operatingHours: 8.2,
          totalOperatingHours: 18330,
          efficiency: 88.1,
          manufacturer: 'YAMADA製作所',
          model: 'YP-3000',
          lastUpdate: new Date(Date.now() - 1000 * 60 * 1),
          lastMaintenance: '2023-11-15',
          sensors: [
            {
              type: 'temperature',
              name: '温度',
              value: 68.5,
              unit: '℃',
              minValue: 20,
              maxValue: 60,
              isWarning: true,
              isError: false,
              trend: '上昇傾向'
            },
            {
              type: 'vibration',
              name: '振動',
              value: 1.2,
              unit: 'mm/s',
              minValue: 0,
              maxValue: 2.0,
              isWarning: false,
              isError: false,
              trend: '安定'
            },
            {
              type: 'current',
              name: '電流',
              value: 17.8,
              unit: 'A',
              minValue: 5,
              maxValue: 20,
              isWarning: false,
              isError: false,
              trend: '安定'
            }
          ],
          recentAlerts: [
            {
              id: 'A001',
              message: '温度が基準値を超えています',
              severity: 'warning',
              timestamp: new Date(Date.now() - 1000 * 60 * 15)
            }
          ]
        },
        {
          id: 'EQ003',
          name: 'コンベア #A1',
          type: 'コンベア',
          location: 'エリアA-コンベア',
          area: 'A',
          status: 'running',
          operatingHours: 8.0,
          totalOperatingHours: 22150,
          efficiency: 95.2,
          manufacturer: 'SUZUKI機械',
          model: 'SC-1200',
          lastUpdate: new Date(Date.now() - 1000 * 60 * 3),
          lastMaintenance: '2024-12-05',
          sensors: [
            {
              type: 'speed',
              name: '速度',
              value: 1.2,
              unit: 'm/s',
              minValue: 0.5,
              maxValue: 2.0,
              isWarning: false,
              isError: false,
              trend: '安定'
            },
            {
              type: 'current',
              name: '電流',
              value: 8.5,
              unit: 'A',
              minValue: 3,
              maxValue: 15,
              isWarning: false,
              isError: false,
              trend: '安定'
            }
          ],
          recentAlerts: []
        },
        {
          id: 'EQ004',
          name: 'ボイラー #1',
          type: 'ボイラー',
          location: 'エリアB-ユーティリティ',
          area: 'B',
          status: 'running',
          operatingHours: 24.0,
          totalOperatingHours: 35200,
          efficiency: 89.7,
          manufacturer: 'TANAKA工業',
          model: 'TB-5000',
          lastUpdate: new Date(Date.now() - 1000 * 60 * 1),
          lastMaintenance: '2024-11-20',
          sensors: [
            {
              type: 'temperature',
              name: '水温',
              value: 85.2,
              unit: '℃',
              minValue: 70,
              maxValue: 95,
              isWarning: false,
              isError: false,
              trend: '安定'
            },
            {
              type: 'pressure',
              name: '圧力',
              value: 0.7,
              unit: 'MPa',
              minValue: 0.3,
              maxValue: 1.0,
              isWarning: false,
              isError: false,
              trend: '安定'
            }
          ],
          recentAlerts: []
        },
        {
          id: 'EQ005',
          name: 'エアコンプレッサー #1',
          type: 'コンプレッサー',
          location: 'エリアC-ユーティリティ',
          area: 'C',
          status: 'error',
          operatingHours: 2.1,
          totalOperatingHours: 28900,
          efficiency: 45.2,
          manufacturer: 'SATO機器',
          model: 'AC-800',
          lastUpdate: new Date(Date.now() - 1000 * 60 * 5),
          lastMaintenance: '2024-10-15',
          sensors: [
            {
              type: 'pressure',
              name: '吐出圧力',
              value: 0.2,
              unit: 'MPa',
              minValue: 0.6,
              maxValue: 0.8,
              isWarning: false,
              isError: true,
              trend: '低下傾向'
            },
            {
              type: 'temperature',
              name: '温度',
              value: 92.1,
              unit: '℃',
              minValue: 40,
              maxValue: 80,
              isWarning: false,
              isError: true,
              trend: '上昇傾向'
            }
          ],
          recentAlerts: [
            {
              id: 'A002',
              message: '吐出圧力が異常に低下しています',
              severity: 'error',
              timestamp: new Date(Date.now() - 1000 * 60 * 5)
            },
            {
              id: 'A003',
              message: '温度が異常に上昇しています',
              severity: 'error',
              timestamp: new Date(Date.now() - 1000 * 60 * 7)
            }
          ]
        },
        {
          id: 'EQ006',
          name: 'ポンプ #3',
          type: 'ポンプ',
          location: 'エリアB-給水設備',
          area: 'B',
          status: 'stopped',
          operatingHours: 0,
          totalOperatingHours: 19850,
          efficiency: 0,
          manufacturer: 'WATANABE水機',
          model: 'WP-200',
          lastUpdate: new Date(Date.now() - 1000 * 60 * 30),
          lastMaintenance: '2024-12-18',
          sensors: [
            {
              type: 'flow',
              name: '流量',
              value: 0,
              unit: 'L/min',
              minValue: 50,
              maxValue: 200,
              isWarning: false,
              isError: false,
              trend: '停止中'
            },
            {
              type: 'pressure',
              name: '圧力',
              value: 0,
              unit: 'kPa',
              minValue: 100,
              maxValue: 500,
              isWarning: false,
              isError: false,
              trend: '停止中'
            }
          ],
          recentAlerts: []
        }
      ]
    }
  },
  computed: {
    filteredEquipment() {
      if (!this.selectedArea) {
        return this.equipmentList
      }
      return this.equipmentList.filter(eq => eq.area === this.selectedArea)
    },
    runningCount() {
      return this.filteredEquipment.filter(eq => eq.status === 'running').length
    },
    stoppedCount() {
      return this.filteredEquipment.filter(eq => eq.status === 'stopped').length
    },
    alertCount() {
      return this.filteredEquipment.filter(eq => eq.status === 'error' || eq.status === 'warning').length
    },
    averageEfficiency() {
      const runningEquipment = this.filteredEquipment.filter(eq => eq.status === 'running')
      if (runningEquipment.length === 0) return 0
      const total = runningEquipment.reduce((sum, eq) => sum + eq.efficiency, 0)
      return Math.round(total / runningEquipment.length * 10) / 10
    }
  },
  methods: {
    getStatusText(status) {
      const statusMap = {
        running: '稼働中',
        stopped: '停止中',
        warning: '注意',
        error: '異常',
        maintenance: 'メンテナンス中'
      }
      return statusMap[status] || '不明'
    },
    formatTime(timestamp) {
      return timestamp.toLocaleTimeString('ja-JP', {
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    filterByArea() {
      // エリアフィルタリングは computed で自動実行される
    },
    refreshData() {
      // データ更新のシミュレーション
      console.log('設備データを更新中...')
      
      // 各設備の最終更新時刻を現在時刻に更新
      this.equipmentList.forEach(equipment => {
        equipment.lastUpdate = new Date()
        
        // センサー値をランダムに少し変動させる
        equipment.sensors.forEach(sensor => {
          if (sensor.type === 'temperature') {
            sensor.value = Math.round((sensor.value + (Math.random() - 0.5) * 2) * 10) / 10
          } else if (sensor.type === 'current') {
            sensor.value = Math.round((sensor.value + (Math.random() - 0.5) * 0.5) * 10) / 10
          }
        })
      })
      
      alert('設備データを更新しました')
    },
    showDetails(equipment) {
      this.selectedEquipment = equipment
    },
    closeModal() {
      this.selectedEquipment = null
    },
    acknowledgeAlert(equipment) {
      // アラート確認処理のシミュレーション
      console.log(`${equipment.name}のアラートを確認しました`)
      alert(`${equipment.name}のアラートを確認しました`)
    }
  }
}
</script>

<style scoped>
.equipment-status {
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.page-header h2 {
  color: #2c3e50;
  margin: 0;
}

.header-controls {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.area-selector {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.9rem;
}

.status-overview {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.overview-item {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.overview-value {
  font-size: 2rem;
  font-weight: bold;
  color: #2c3e50;
  display: block;
}

.overview-label {
  font-size: 0.9rem;
  color: #7f8c8d;
  margin-top: 0.5rem;
}

.equipment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 1.5rem;
}

.equipment-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  transition: transform 0.2s, box-shadow 0.2s;
}

.equipment-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

.equipment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.equipment-name {
  color: #2c3e50;
  margin: 0;
  font-size: 1.2rem;
}

.status-badge {
  padding: 0.3rem 0.8rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: bold;
  text-transform: uppercase;
}

.status-running {
  background-color: #d5f4e6;
  color: #27ae60;
}

.status-stopped {
  background-color: #fadbd8;
  color: #e74c3c;
}

.status-warning {
  background-color: #fef5e7;
  color: #f39c12;
}

.status-error {
  background-color: #fadbd8;
  color: #e74c3c;
}

.equipment-info {
  margin-bottom: 1rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.info-label {
  color: #7f8c8d;
  font-weight: 500;
}

.info-value {
  color: #2c3e50;
  font-weight: bold;
}

.sensor-data {
  margin-bottom: 1rem;
}

.sensor-data h4 {
  color: #2c3e50;
  margin-bottom: 0.75rem;
  font-size: 1rem;
}

.sensor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 0.75rem;
}

.sensor-item {
  background-color: #f8f9fa;
  padding: 0.75rem;
  border-radius: 6px;
  text-align: center;
}

.sensor-type {
  font-size: 0.8rem;
  color: #7f8c8d;
  margin-bottom: 0.25rem;
}

.sensor-value {
  font-size: 1.1rem;
  font-weight: bold;
  color: #2c3e50;
  margin-bottom: 0.25rem;
}

.sensor-value.warning {
  color: #f39c12;
}

.sensor-value.error {
  color: #e74c3c;
}

.sensor-status {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
}

.sensor-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 0.25rem;
}

.recent-alerts {
  margin-bottom: 1rem;
}

.recent-alerts h4 {
  color: #2c3e50;
  margin-bottom: 0.75rem;
  font-size: 1rem;
}

.alert-item-mini {
  display: flex;
  align-items: center;
  padding: 0.5rem;
  background-color: #f8f9fa;
  border-radius: 4px;
  margin-bottom: 0.5rem;
}

.alert-text {
  flex: 1;
  margin: 0 0.5rem;
  font-size: 0.9rem;
  color: #2c3e50;
}

.alert-time {
  font-size: 0.8rem;
  color: #7f8c8d;
}

.equipment-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.btn-sm {
  padding: 0.4rem 0.8rem;
  font-size: 0.8rem;
}

.btn-warning {
  background-color: #f39c12;
  color: white;
}

.btn-warning:hover {
  background-color: #e67e22;
}

/* モーダル */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  margin: 1rem;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #ecf0f1;
}

.modal-header h3 {
  margin: 0;
  color: #2c3e50;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #7f8c8d;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  color: #2c3e50;
}

.modal-body {
  padding: 1.5rem;
}

.detail-section {
  margin-bottom: 2rem;
}

.detail-section h4 {
  color: #2c3e50;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #ecf0f1;
}

.detail-table {
  width: 100%;
  border-collapse: collapse;
}

.detail-table td {
  padding: 0.5rem;
  border-bottom: 1px solid #ecf0f1;
}

.detail-table td:first-child {
  font-weight: bold;
  color: #7f8c8d;
  width: 30%;
}

.sensor-detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.sensor-detail-item {
  background-color: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
}

.sensor-detail-item h5 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.sensor-detail-value {
  font-size: 1.2rem;
  font-weight: bold;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.sensor-detail-range,
.sensor-history {
  font-size: 0.8rem;
  color: #7f8c8d;
  margin-bottom: 0.25rem;
}

/* レスポンシブ対応 */
@media (max-width: 768px) {
  .equipment-grid {
    grid-template-columns: 1fr;
  }
  
  .page-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .header-controls {
    justify-content: space-between;
  }
  
  .status-overview {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .modal-content {
    margin: 0.5rem;
    max-height: 95vh;
  }
  
  .sensor-detail-grid {
    grid-template-columns: 1fr;
  }
}
</style>