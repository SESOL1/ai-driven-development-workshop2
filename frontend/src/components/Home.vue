<template>
  <div class="home">
    <div class="welcome-section">
      <h2>工場設備監視システムへようこそ</h2>
      <p>リアルタイムで設備の稼働状況を監視し、効率的な工場運営をサポートします。</p>
    </div>
    
    <div class="dashboard-grid">
      <!-- システム概要カード -->
      <div class="card overview-card">
        <h3>システム概要</h3>
        <div class="stats-grid">
          <div class="stat-item">
            <span class="stat-number">{{ systemStats.totalEquipment }}</span>
            <span class="stat-label">総設備数</span>
          </div>
          <div class="stat-item">
            <span class="stat-number">{{ systemStats.activeEquipment }}</span>
            <span class="stat-label">稼働中</span>
          </div>
          <div class="stat-item">
            <span class="stat-number">{{ systemStats.alertCount }}</span>
            <span class="stat-label">アラート</span>
          </div>
          <div class="stat-item">
            <span class="stat-number">{{ systemStats.efficiency }}%</span>
            <span class="stat-label">全体効率</span>
          </div>
        </div>
      </div>
      
      <!-- 最新アラートカード -->
      <div class="card alerts-card">
        <h3>最新アラート</h3>
        <div class="alert-list">
          <div v-for="alert in recentAlerts" :key="alert.id" class="alert-item">
            <span :class="['status-indicator', `status-${alert.severity}`]"></span>
            <div class="alert-content">
              <div class="alert-equipment">{{ alert.equipmentName }}</div>
              <div class="alert-message">{{ alert.message }}</div>
              <div class="alert-time">{{ formatTime(alert.timestamp) }}</div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 稼働率グラフカード -->
      <div class="card chart-card">
        <h3>今日の稼働率</h3>
        <div class="chart-container">
          <div class="simple-chart">
            <div v-for="(rate, index) in hourlyRates" :key="index" class="chart-bar">
              <div class="bar" :style="{ height: rate + '%' }"></div>
              <span class="bar-label">{{ index + 6 }}時</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- メンテナンス予定カード -->
      <div class="card maintenance-card">
        <h3>本日のメンテナンス予定</h3>
        <div class="maintenance-list">
          <div v-for="maintenance in todayMaintenance" :key="maintenance.id" class="maintenance-item">
            <div class="maintenance-time">{{ maintenance.scheduledTime }}</div>
            <div class="maintenance-content">
              <div class="maintenance-equipment">{{ maintenance.equipmentName }}</div>
              <div class="maintenance-type">{{ maintenance.type }}</div>
            </div>
            <button class="btn btn-primary btn-sm">詳細</button>
          </div>
        </div>
        <div v-if="todayMaintenance.length === 0" class="no-maintenance">
          本日のメンテナンス予定はありません
        </div>
      </div>
      
      <!-- クイックアクションカード -->
      <div class="card actions-card">
        <h3>クイックアクション</h3>
        <div class="action-buttons">
          <router-link to="/equipment-status" class="btn btn-primary">設備状況確認</router-link>
          <button class="btn btn-success" @click="refreshData">データ更新</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Home',
  data() {
    return {
      systemStats: {
        totalEquipment: 24,
        activeEquipment: 21,
        alertCount: 3,
        efficiency: 87.5
      },
      recentAlerts: [
        {
          id: 1,
          equipmentName: 'プレス機 #3',
          message: '温度が高温域に達しています',
          severity: 'warning',
          timestamp: new Date(Date.now() - 1000 * 60 * 15) // 15分前
        },
        {
          id: 2,
          equipmentName: 'コンベア #A2',
          message: '振動値が通常より高くなっています',
          severity: 'warning',
          timestamp: new Date(Date.now() - 1000 * 60 * 45) // 45分前
        },
        {
          id: 3,
          equipmentName: 'ポンプ #7',
          message: '定期メンテナンスの時期です',
          severity: 'normal',
          timestamp: new Date(Date.now() - 1000 * 60 * 120) // 2時間前
        }
      ],
      hourlyRates: [85, 87, 90, 88, 92, 89, 85, 91, 88, 86, 89, 92], // 6時から17時までの稼働率
      todayMaintenance: [
        {
          id: 1,
          equipmentName: 'ボイラー #1',
          type: '定期点検',
          scheduledTime: '10:00'
        },
        {
          id: 2,
          equipmentName: 'エアコンプレッサー #2',
          type: 'フィルター交換',
          scheduledTime: '14:00'
        }
      ]
    }
  },
  mounted() {
    // 実際のシステムでは、ここでAPIからデータを取得
    this.loadData()
  },
  methods: {
    formatTime(timestamp) {
      return timestamp.toLocaleTimeString('ja-JP', {
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    loadData() {
      // サンプルデータの読み込み
      console.log('データを読み込み中...')
    },
    refreshData() {
      // データの更新
      console.log('データを更新中...')
      // 実際のシステムでは、ここでAPIを呼び出してデータを更新
      alert('データを更新しました')
    }
  }
}
</script>

<style scoped>
.home {
  max-width: 1200px;
  margin: 0 auto;
}

.welcome-section {
  text-align: center;
  margin-bottom: 2rem;
}

.welcome-section h2 {
  color: #2c3e50;
  margin-bottom: 1rem;
  font-size: 2rem;
}

.welcome-section p {
  color: #7f8c8d;
  font-size: 1.1rem;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
}

.overview-card {
  grid-column: span 2;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  margin-top: 1rem;
}

.stat-item {
  text-align: center;
  padding: 1rem;
  background-color: #ecf0f1;
  border-radius: 6px;
}

.stat-number {
  display: block;
  font-size: 2rem;
  font-weight: bold;
  color: #2c3e50;
}

.stat-label {
  font-size: 0.9rem;
  color: #7f8c8d;
}

.alert-list {
  max-height: 200px;
  overflow-y: auto;
}

.alert-item {
  display: flex;
  align-items: flex-start;
  padding: 0.75rem 0;
  border-bottom: 1px solid #ecf0f1;
}

.alert-item:last-child {
  border-bottom: none;
}

.alert-content {
  flex: 1;
  margin-left: 0.5rem;
}

.alert-equipment {
  font-weight: bold;
  color: #2c3e50;
}

.alert-message {
  font-size: 0.9rem;
  color: #7f8c8d;
  margin: 0.25rem 0;
}

.alert-time {
  font-size: 0.8rem;
  color: #95a5a6;
}

.chart-container {
  margin-top: 1rem;
}

.simple-chart {
  display: flex;
  align-items: end;
  height: 120px;
  gap: 4px;
}

.chart-bar {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.bar {
  width: 100%;
  background: linear-gradient(to top, #3498db, #5dade2);
  border-radius: 2px 2px 0 0;
  min-height: 10px;
  transition: all 0.3s ease;
}

.bar:hover {
  transform: scale(1.1);
}

.bar-label {
  margin-top: 0.5rem;
  font-size: 0.8rem;
  color: #7f8c8d;
}

.maintenance-list {
  max-height: 200px;
  overflow-y: auto;
}

.maintenance-item {
  display: flex;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid #ecf0f1;
}

.maintenance-item:last-child {
  border-bottom: none;
}

.maintenance-time {
  font-weight: bold;
  color: #e67e22;
  margin-right: 1rem;
  min-width: 60px;
}

.maintenance-content {
  flex: 1;
}

.maintenance-equipment {
  font-weight: bold;
  color: #2c3e50;
}

.maintenance-type {
  font-size: 0.9rem;
  color: #7f8c8d;
}

.no-maintenance {
  text-align: center;
  color: #95a5a6;
  padding: 2rem;
  font-style: italic;
}

.action-buttons {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.action-buttons .btn {
  flex: 1;
  min-width: 120px;
}

.btn-sm {
  padding: 0.3rem 0.6rem;
  font-size: 0.8rem;
}

/* レスポンシブ対応 */
@media (max-width: 768px) {
  .overview-card {
    grid-column: span 1;
  }
  
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
}
</style>