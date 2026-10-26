<template>
  <div class="auction">
    <!-- ================= 顶部导航栏（复用 TopNav） ================= -->
    <TopNav
      :username="username"
      :permission="permission"
      active="auction"
      @nav="(k) => emit('nav', k)"
      @logout="emit('logout')"
      @admin="emit('admin')"
    />

    <main class="wrap">
      <!-- ================= 页头 ================= -->
      <section class="head">
        <div>
          <h1>臻品竞拍</h1>
          <p>甄选全球稀缺臻品 · 实时竞价 · 尊享专属礼遇</p>
        </div>
        <div class="head-stat">
          <div><span>{{ liveCount }}</span><i>进行中</i></div>
          <div><span>{{ lots.length }}</span><i>总拍品</i></div>
        </div>
      </section>

      <!-- ================= 筛选栏 ================= -->
      <section class="filter">
        <div class="cats">
          <button
            v-for="c in ['全部', ...categories]"
            :key="c"
            :class="['chip', { on: activeCat === c }]"
            type="button"
            @click="activeCat = c"
          >{{ c }}</button>
        </div>

        <div class="filter-row">
          <div class="tabs">
            <button
              v-for="s in ['全部', '进行中', '即将开始', '已结束']"
              :key="s"
              :class="['tab', { on: activeStatus === s }]"
              type="button"
              @click="activeStatus = s"
            >{{ s }}</button>
          </div>

          <div class="right">
            <input
              v-model.trim="keyword"
              class="search"
              type="text"
              placeholder="搜索拍品名称 / 关键词"
              aria-label="搜索拍品"
            />
            <select v-model="activeSort" class="sort" aria-label="排序方式">
              <option value="default">综合排序</option>
              <option value="ending">即将结束</option>
              <option value="price-asc">价格 ↑</option>
              <option value="price-desc">价格 ↓</option>
              <option value="hot">热度优先</option>
            </select>
          </div>
        </div>
      </section>

      <!-- ================= 主体：拍品网格 + 实时动态 ================= -->
      <div class="body">
        <div class="grid">
          <article v-for="lot in filteredLots" :key="lot.id" class="card">
            <div class="cover" :style="{ '--hue': lot.hue }">
              <span class="cover-icon">{{ lot.icon }}</span>
              <span class="cat-tag">{{ lot.category }}</span>
              <span class="phase" :class="phaseOf(lot)">
                <i v-if="phaseOf(lot) === 'live'" class="dot"></i>
                {{ phaseLabel(phaseOf(lot)) }}
              </span>
            </div>

            <div class="card-body">
              <h3>{{ lot.title }}</h3>
              <p class="desc">{{ lot.desc }}</p>

              <div class="price">
                <div>
                  <span class="label">当前价</span>
                  <b class="cur">{{ fmtMoney(lot.currentPrice) }}</b>
                </div>
                <div class="sub">起拍 {{ fmtMoney(lot.startPrice) }}</div>
              </div>

              <div class="meta">
                <span>🔨 {{ lot.bidCount }} 次出价</span>
                <span>👁 {{ lot.watch }} 人关注</span>
              </div>

              <div class="countdown" :class="phaseOf(lot)">
                <template v-if="phaseOf(lot) === 'live'">
                  <span class="cd-label">距结束</span>
                  <span class="cd-val">{{ fmtRemain(lot.endTime - now) }}</span>
                </template>
                <template v-else-if="phaseOf(lot) === 'upcoming'">
                  <span class="cd-label">距开始</span>
                  <span class="cd-val">{{ fmtRemain(lot.openTime - now) }}</span>
                </template>
                <template v-else>
                  <span class="cd-label">已结束</span>
                  <span class="cd-val ended">拍卖落槌</span>
                </template>
              </div>

              <button
                class="bid-btn"
                type="button"
                :disabled="phaseOf(lot) !== 'live'"
                @click="openBid(lot)"
              >
                {{ phaseOf(lot) === 'live' ? '立即出价' : (phaseOf(lot) === 'upcoming' ? '未开拍' : '已结束') }}
              </button>
            </div>
          </article>

          <p v-if="!filteredLots.length" class="empty">未找到符合条件的拍品，调整筛选试试</p>
        </div>

        <!-- 实时出价动态 -->
        <aside class="aside">
          <div class="aside-head">
            <h2>实时出价动态</h2>
            <span class="live-dot"></span>
          </div>
          <ul class="feed">
            <li v-for="(a, idx) in activity" :key="idx">
              <div class="feed-top">
                <span class="feed-user">{{ a.user }}</span>
                <span class="feed-amt">{{ fmtMoney(a.amount) }}</span>
              </div>
              <div class="feed-bot">
                <span class="feed-lot">{{ a.lot }}</span>
                <span class="feed-time">{{ fmtTime(a.time) }}</span>
              </div>
            </li>
            <li v-if="!activity.length" class="feed-empty">暂无出价记录</li>
          </ul>
        </aside>
      </div>
    </main>

    <!-- ================= 出价弹窗 ================= -->
    <transition name="fade">
      <div v-if="bidLot" class="mask" @click.self="closeBid">
        <div class="modal">
          <div class="modal-head">
            <h3>确认出价</h3>
            <button class="x" type="button" @click="closeBid">✕</button>
          </div>

          <div class="modal-body">
            <div class="lot-summary">
              <span class="lot-icon">{{ bidLot.icon }}</span>
              <div>
                <div class="lot-title">{{ bidLot.title }}</div>
                <div class="lot-cat">{{ bidLot.category }}</div>
              </div>
            </div>

            <div class="price-line">
              <div>
                <span>当前最高价</span>
                <b>{{ fmtMoney(bidLot.currentPrice) }}</b>
              </div>
              <div>
                <span>最低加价幅度</span>
                <b>{{ fmtMoney(bidLot.increment) }}</b>
              </div>
            </div>

            <label class="bid-label">您的出价</label>
            <div class="bid-input">
              <span class="yen">¥</span>
              <input
                v-model.number="bidAmount"
                type="number"
                :min="bidLot.currentPrice + bidLot.increment"
                aria-label="出价金额"
              />
            </div>

            <div class="quick">
              <button
                v-for="m in [1, 2, 5]"
                :key="m"
                type="button"
                @click="quickBid(m)"
              >+{{ fmtMoney(bidLot.increment * m) }}</button>
            </div>

            <p v-if="bidError" class="bid-error">{{ bidError }}</p>

            <div class="records">
              <div class="records-head">出价记录（{{ bidLot.bidCount }}）</div>
              <ul class="records-list">
                <li v-for="(b, i) in bidLot.bids" :key="i">
                  <span class="rb-user">{{ b.user }}<em v-if="i === 0"> · 领先</em></span>
                  <span class="rb-amt">{{ fmtMoney(b.amount) }}</span>
                  <span class="rb-time">{{ fmtTime(b.time) }}</span>
                </li>
                <li v-if="!bidLot.bids.length" class="rb-empty">暂无出价，抢先出价</li>
              </ul>
            </div>
          </div>

          <div class="modal-foot">
            <button class="ghost" type="button" @click="closeBid">取消</button>
            <button class="confirm" type="button" @click="confirmBid">确认出价</button>
          </div>
        </div>
      </div>
    </transition>

    <!-- ================= 轻提示 ================= -->
    <transition name="toast">
      <div v-if="toast" class="toast">{{ toast }}</div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import TopNav from './TopNav.vue'
import { getAuctionLots, placeBid } from '../api.js'

const props = defineProps({
  username: { type: String, default: '' },
  // 0 管理员，1 默认会员
  permission: { type: Number, default: 1 }
})
const emit = defineEmits(['nav', 'logout', 'admin'])

/* =====================================================================
 * 后端预留接口（对接 Spring Boot 8080）
 *   GET  /api/auction/lots        -> 拍品列表（含起拍价/当前价/出价记录/起止时间）
 *   POST /api/auction/bid         -> 出价 { lotId, amount }
 * 当前为前端 mock 数据，后端就绪后替换下方 lots 初始化与 confirmBid 内的请求即可。
 * ===================================================================== */

/* ---------------- 全局时钟（驱动所有倒计时） ---------------- */
const now = ref(Date.now())
let timer = null
onMounted(() => {
  timer = setInterval(() => { now.value = Date.now() }, 1000)
})
onBeforeUnmount(() => { if (timer) clearInterval(timer) })

/* ---------------- 工具函数 ---------------- */
const fmtMoney = (n) => '¥' + Number(n).toLocaleString('zh-CN')
const pad = (n) => String(n).padStart(2, '0')
function fmtRemain(ms) {
  const t = Math.max(0, ms)
  const d = Math.floor(t / 86400000)
  const h = Math.floor((t % 86400000) / 3600000)
  const m = Math.floor((t % 3600000) / 60000)
  const s = Math.floor((t % 60000) / 1000)
  if (d > 0) return `${d}天 ${pad(h)}:${pad(m)}:${pad(s)}`
  return `${pad(h)}:${pad(m)}:${pad(s)}`
}
function fmtTime(ts) {
  const d = new Date(ts)
  return `${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

/* ---------------- Mock 数据 ---------------- */
const H = 3600000
const M = 60000
const base = Date.now()

const categories = ['艺术珍品', '珠宝腕表', '珍稀佳酿', '奢品皮具', '私享体验']

const lots = ref([
  {
    id: 1,
    title: '赵无极 · 抽象水墨《风起》',
    category: '艺术珍品',
    icon: '🖼️',
    hue: 38,
    desc: '二十世纪抽象大师晚年代表作，绢本水墨，附鉴定证书与展览记录。',
    startPrice: 1200000,
    currentPrice: 1860000,
    increment: 50000,
    openTime: base - 2 * H,
    endTime: base + 5 * H,
    bidCount: 23,
    watch: 156,
    bids: [
      { user: '会员 C***', amount: 1860000, time: base - 8 * M },
      { user: '会员 L***', amount: 1810000, time: base - 25 * M },
      { user: '会员 W***', amount: 1760000, time: base - 70 * M }
    ]
  },
  {
    id: 2,
    title: '百达翡丽 5711 蓝盘腕表',
    category: '珠宝腕表',
    icon: '⌚',
    hue: 42,
    desc: '经典 Nautilus 运动钢表，附原厂保卡与表盒，品相近全新。',
    startPrice: 380000,
    currentPrice: 520000,
    increment: 20000,
    openTime: base - 1 * H,
    endTime: base + 3 * H,
    bidCount: 17,
    watch: 203,
    bids: [
      { user: '会员 Z***', amount: 520000, time: base - 5 * M },
      { user: '会员 Q***', amount: 500000, time: base - 40 * M }
    ]
  },
  {
    id: 3,
    title: '罗曼尼康帝 1999 整箱（6 瓶）',
    category: '珍稀佳酿',
    icon: '🍷',
    hue: 34,
    desc: '勃艮第之王巅峰年份，原木箱封存，恒温酒窖直出。',
    startPrice: 600000,
    currentPrice: 880000,
    increment: 30000,
    openTime: base - 30 * M,
    endTime: base + 8 * H,
    bidCount: 31,
    watch: 178,
    bids: [
      { user: '会员 K***', amount: 880000, time: base - 2 * M },
      { user: '会员 X***', amount: 850000, time: base - 18 * M },
      { user: '会员 M***', amount: 820000, time: base - 55 * M }
    ]
  },
  {
    id: 4,
    title: '爱马仕 喜马拉雅 Birkin 25',
    category: '奢品皮具',
    icon: '👜',
    hue: 46,
    desc: '雾面尼罗鳄鱼皮搭配白金件，殿堂级收藏，即将开拍。',
    startPrice: 900000,
    currentPrice: 900000,
    increment: 50000,
    openTime: base + 2 * H,
    endTime: base + 26 * H,
    bidCount: 0,
    watch: 264,
    bids: []
  },
  {
    id: 5,
    title: '私人岛屿 48 小时包船体验',
    category: '私享体验',
    icon: '🛥️',
    hue: 36,
    desc: '地中海蓝岸专属行程，含米其林主厨随行与管家团队。',
    startPrice: 150000,
    currentPrice: 210000,
    increment: 10000,
    openTime: base - 6 * H,
    endTime: base + 1 * H,
    bidCount: 12,
    watch: 97,
    bids: [
      { user: '会员 V***', amount: 210000, time: base - 12 * M },
      { user: '会员 D***', amount: 200000, time: base - 60 * M }
    ]
  },
  {
    id: 6,
    title: '常玉《曲腿裸女》素描手稿',
    category: '艺术珍品',
    icon: '✏️',
    hue: 40,
    desc: '二十世纪东方现代主义先驱纸本素描，已结束拍卖。',
    startPrice: 800000,
    currentPrice: 1500000,
    increment: 50000,
    openTime: base - 48 * H,
    endTime: base - 20 * H,
    bidCount: 41,
    watch: 312,
    bids: [
      { user: '会员 S***', amount: 1500000, time: base - 21 * H },
      { user: '会员 R***', amount: 1450000, time: base - 22 * H }
    ]
  },
  {
    id: 7,
    title: '卡地亚 猎豹胸针',
    category: '珠宝腕表',
    icon: '💎',
    hue: 44,
    desc: '18K 黄金镶嵌缟玛瑙与钻石，品牌档案可查，附证书。',
    startPrice: 260000,
    currentPrice: 360000,
    increment: 15000,
    openTime: base - 4 * H,
    endTime: base + 12 * H,
    bidCount: 9,
    watch: 121,
    bids: [
      { user: '会员 F***', amount: 360000, time: base - 15 * M },
      { user: '会员 G***', amount: 345000, time: base - 90 * M }
    ]
  },
  {
    id: 8,
    title: '麦卡伦 1926 单一麦芽威士忌',
    category: '珍稀佳酿',
    icon: '🥃',
    hue: 32,
    desc: '传奇年份珍稀装瓶，全球极少数量，即将开拍。',
    startPrice: 1500000,
    currentPrice: 1500000,
    increment: 100000,
    openTime: base + 5 * H,
    endTime: base + 29 * H,
    bidCount: 0,
    watch: 188,
    bids: []
  },
  {
    id: 9,
    title: '路易威登 古董硬箱旅行套装',
    category: '奢品皮具',
    icon: '🧳',
    hue: 48,
    desc: '1920 年代定制硬箱，含梳妆与文具隔层，收藏级品相。',
    startPrice: 120000,
    currentPrice: 175000,
    increment: 8000,
    openTime: base - 3 * H,
    endTime: base + 6 * H,
    bidCount: 14,
    watch: 83,
    bids: [
      { user: '会员 B***', amount: 175000, time: base - 7 * M },
      { user: '会员 N***', amount: 167000, time: base - 48 * M }
    ]
  }
])

/* ---------------- 拍品状态 / 筛选 / 排序 ---------------- */
function phaseOf(lot) {
  const t = now.value
  if (t < lot.openTime) return 'upcoming'
  if (t < lot.endTime) return 'live'
  return 'ended'
}
function phaseLabel(p) {
  return p === 'live' ? '进行中' : p === 'upcoming' ? '即将开始' : '已结束'
}
const statusMap = { '进行中': 'live', '即将开始': 'upcoming', '已结束': 'ended' }

const keyword = ref('')
const activeCat = ref('全部')
const activeStatus = ref('全部')
const activeSort = ref('default')

const liveCount = computed(() => lots.value.filter((l) => phaseOf(l) === 'live').length)

const filteredLots = computed(() => {
  let list = lots.value
  if (activeCat.value !== '全部') {
    list = list.filter((l) => l.category === activeCat.value)
  }
  if (activeStatus.value !== '全部') {
    const want = statusMap[activeStatus.value]
    list = list.filter((l) => phaseOf(l) === want)
  }
  const k = keyword.value.trim().toLowerCase()
  if (k) {
    list = list.filter(
      (l) => l.title.toLowerCase().includes(k) || l.desc.toLowerCase().includes(k)
    )
  }
  list = [...list]
  switch (activeSort.value) {
    case 'price-asc': list.sort((a, b) => a.currentPrice - b.currentPrice); break
    case 'price-desc': list.sort((a, b) => b.currentPrice - a.currentPrice); break
    case 'ending': list.sort((a, b) => a.endTime - b.endTime); break
    case 'hot': list.sort((a, b) => b.watch - a.watch); break
  }
  return list
})

/* ---------------- 出价弹窗 ---------------- */
const bidLot = ref(null)
const bidAmount = ref(0)
const bidError = ref('')
const toast = ref('')
let toastTimer = null

function showToast(msg) {
  toast.value = msg
  if (toastTimer) clearTimeout(toastTimer)
  toastTimer = setTimeout(() => { toast.value = '' }, 2200)
}

function openBid(lot) {
  if (phaseOf(lot) !== 'live') {
    showToast('该拍品暂未开拍或已结束')
    return
  }
  bidLot.value = lot
  bidAmount.value = lot.currentPrice + lot.increment
  bidError.value = ''
}

function closeBid() {
  bidLot.value = null
}

function quickBid(mult) {
  if (!bidLot.value) return
  bidAmount.value = bidLot.value.currentPrice + bidLot.value.increment * mult
  bidError.value = ''
}

function confirmBid() {
  const lot = bidLot.value
  if (!lot) return
  if (phaseOf(lot) !== 'live') {
    showToast('拍卖已结束，无法出价')
    return
  }
  const amt = Number(bidAmount.value)
  const min = lot.currentPrice + lot.increment
  if (!amt || amt < min) {
    bidError.value = `出价需不低于 ${fmtMoney(min)}`
    return
  }
  lot.currentPrice = amt
  lot.bidCount += 1
  const record = { user: props.username || '尊贵会员', amount: amt, time: Date.now() }
  lot.bids.unshift(record)
  activity.unshift({ ...record, lot: lot.title })
  closeBid()
  showToast('出价成功，您当前为最高出价者')

  // 异步同步到后端（失败不影响本地展示，由页面兜底）
  placeBid(lot.id, amt)
    .then((updated) => {
      if (updated) {
        lot.currentPrice = updated.currentPrice
        lot.bidCount = updated.bidCount
        lot.bids = updated.bids
      }
    })
    .catch(() => {
      /* 后端未启动或出价被拒：本地已兜底，无需额外处理 */
    })
}

/* ---------------- 实时出价动态（出价记录聚合） ---------------- */
const activity = ref([])
onMounted(async () => {
  // 优先从后端拉取拍品；后端未启动（返回 null）则保留本地 mock 演示数据
  const remote = await getAuctionLots()
  if (remote && remote.length) {
    lots.value = remote
  }
  lots.value.forEach((l) => {
    (l.bids || []).slice(0, 2).forEach((b) => {
      activity.unshift({ ...b, lot: l.title })
    })
  })
  activity.value.sort((a, b) => b.time - a.time)
})
</script>

<style scoped lang="scss">
$line: var(--line);
$bg1: var(--bg-1);
$bg2: var(--bg-2);
$gold: var(--gold);
$goldSoft: var(--gold-soft);
$text: var(--text);
$textDim: var(--text-dim);
$serif: var(--serif);

.auction {
  width: 100%;
  color: $text;
}

.wrap {
  max-width: 1180px;
  margin: 0 auto;
  padding: 40px 16px 64px;
}

/* ============ 页头 ============ */
.head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 20px;
  padding-bottom: 24px;
  border-bottom: 1px solid $line;
  flex-wrap: wrap;

  h1 {
    font-family: $serif;
    font-size: 34px;
    font-weight: 500;
    letter-spacing: 4px;
    color: $goldSoft;
  }
  p {
    margin-top: 10px;
    font-size: 12.5px;
    letter-spacing: 3px;
    color: $textDim;
  }
}

.head-stat {
  display: flex;
  gap: 32px;

  div {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 4px;
  }
  span {
    font-family: $serif;
    font-size: 26px;
    color: $goldSoft;
    line-height: 1;
  }
  i {
    font-style: normal;
    font-size: 11px;
    letter-spacing: 2px;
    color: $textDim;
  }
}

/* ============ 筛选栏 ============ */
.filter {
  margin-top: 28px;
  border: 1px solid $line;
  border-radius: 4px;
  background: linear-gradient(160deg, $bg1, $bg2);
  padding: 16px 18px;
}

.cats {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.chip {
  padding: 7px 16px;
  border: 1px solid $line;
  border-radius: 20px;
  background: transparent;
  color: $textDim;
  font-size: 12.5px;
  letter-spacing: 1px;
  cursor: pointer;
  transition: color 0.2s, border-color 0.2s, background 0.2s;
  font-family: var(--sans);

  &:hover {
    color: $text;
    border-color: #4a4a4a;
  }
  &.on {
    color: #14110b;
    background: linear-gradient(180deg, $goldSoft, $gold);
    border-color: $gold;
    font-weight: 600;
  }
}

.filter-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-top: 16px;
  flex-wrap: wrap;
}

.tabs {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.tab {
  padding: 6px 14px;
  background: transparent;
  border: none;
  color: $textDim;
  font-size: 12.5px;
  letter-spacing: 1px;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: color 0.2s, border-color 0.2s;
  font-family: var(--sans);

  &:hover {
    color: $text;
  }
  &.on {
    color: $goldSoft;
    border-bottom-color: $gold;
  }
}

.right {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.search {
  background: var(--bg-0);
  border: 1px solid $line;
  border-radius: 2px;
  color: $text;
  font-size: 13px;
  font-family: var(--sans);
  padding: 8px 12px;
  outline: none;
  min-width: 200px;
  transition: border-color 0.2s;

  &:focus { border-color: $gold; }
  &::placeholder { color: #555; }
}

.sort {
  background: var(--bg-0);
  border: 1px solid $line;
  border-radius: 2px;
  color: $text;
  font-size: 13px;
  font-family: var(--sans);
  padding: 8px 12px;
  outline: none;
  cursor: pointer;

  &:focus { border-color: $gold; }
}

/* ============ 主体布局 ============ */
.body {
  display: flex;
  gap: 24px;
  align-items: flex-start;
  margin-top: 28px;
}

.grid {
  flex: 1;
  min-width: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 18px;
}

.empty {
  grid-column: 1 / -1;
  text-align: center;
  padding: 56px 0;
  font-size: 13px;
  letter-spacing: 2px;
  color: $textDim;
}

/* ============ 拍品卡片 ============ */
.card {
  border: 1px solid $line;
  border-radius: 4px;
  background: linear-gradient(160deg, $bg1, $bg2);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  transition: border-color 0.3s, transform 0.25s;

  &:hover {
    border-color: $gold;
    transform: translateY(-3px);
  }
}

.cover {
  position: relative;
  height: 150px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(160deg, hsl(var(--hue, 40) 32% 16%), hsl(var(--hue, 40) 26% 9%));

  &::after {
    content: "";
    position: absolute;
    inset: 0;
    background: radial-gradient(circle at 50% 120%, rgba(201, 169, 106, 0.18), transparent 60%);
  }
}

.cover-icon {
  font-size: 46px;
  filter: drop-shadow(0 4px 10px rgba(0, 0, 0, 0.4));
  position: relative;
  z-index: 1;
}

.cat-tag {
  position: absolute;
  top: 12px;
  left: 12px;
  z-index: 2;
  font-size: 10.5px;
  letter-spacing: 2px;
  color: $goldSoft;
  border: 1px solid rgba(201, 169, 106, 0.4);
  padding: 3px 9px;
  border-radius: 2px;
  background: rgba(0, 0, 0, 0.35);
}

.phase {
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 2;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 10.5px;
  letter-spacing: 1px;
  padding: 3px 9px;
  border-radius: 2px;
  background: rgba(0, 0, 0, 0.4);
  color: $textDim;

  &.live {
    color: #e8c98a;
    border: 1px solid rgba(201, 169, 106, 0.5);
  }
  &.upcoming {
    color: #9fb6c9;
    border: 1px solid rgba(120, 150, 180, 0.4);
  }
  &.ended {
    color: #7a7a7a;
    border: 1px solid #333;
  }
  .dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: $gold;
    animation: pulse 1.4s infinite;
  }
}

.card-body {
  padding: 18px 18px 20px;
  display: flex;
  flex-direction: column;
  flex: 1;

  h3 {
    font-size: 15.5px;
    letter-spacing: 0.5px;
    color: $text;
    font-weight: 600;
    line-height: 1.5;
  }
}

.desc {
  margin-top: 8px;
  font-size: 12px;
  line-height: 1.8;
  color: $textDim;
  letter-spacing: 0.3px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.price {
  margin-top: 16px;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 10px;

  .label {
    display: block;
    font-size: 10.5px;
    letter-spacing: 2px;
    color: $textDim;
    margin-bottom: 4px;
  }
  .cur {
    font-family: $serif;
    font-size: 22px;
    font-weight: 500;
    letter-spacing: 1px;
    color: $goldSoft;
  }
  .sub {
    font-size: 11px;
    letter-spacing: 1px;
    color: #6a6a6a;
    white-space: nowrap;
  }
}

.meta {
  margin-top: 14px;
  display: flex;
  gap: 16px;
  font-size: 11.5px;
  letter-spacing: 0.5px;
  color: $textDim;
}

.countdown {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 14px;
  padding: 9px 12px;
  border-radius: 3px;
  background: rgba(0, 0, 0, 0.3);
  border: 1px solid $line;
  font-size: 12px;

  .cd-label {
    letter-spacing: 2px;
    color: $textDim;
  }
  .cd-val {
    font-variant-numeric: tabular-nums;
    letter-spacing: 1px;
    color: $goldSoft;
    font-weight: 600;
  }
  &.ended .cd-val {
    color: #7a7a7a;
    font-weight: 500;
  }
}

.bid-btn {
  margin-top: 14px;
  width: 100%;
  padding: 11px;
  border: none;
  border-radius: 2px;
  cursor: pointer;
  background: linear-gradient(180deg, $goldSoft, $gold);
  color: #14110b;
  font-size: 13px;
  letter-spacing: 3px;
  font-weight: 500;
  font-family: var(--sans);
  transition: filter 0.25s, transform 0.1s;

  &:hover:not(:disabled) { filter: brightness(1.08); }
  &:active:not(:disabled) { transform: translateY(1px); }
  &:disabled {
    cursor: not-allowed;
    opacity: 0.55;
    background: linear-gradient(180deg, #3a3a3a, #2a2a2a);
    color: #8a8a8a;
  }
}

/* ============ 实时出价动态 ============ */
.aside {
  width: 300px;
  flex: 0 0 300px;
  position: sticky;
  top: 84px;
  border: 1px solid $line;
  border-radius: 4px;
  background: linear-gradient(160deg, $bg1, $bg2);
  max-height: calc(100vh - 110px);
  display: flex;
  flex-direction: column;
}

.aside-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
  border-bottom: 1px solid $line;

  h2 {
    font-family: $serif;
    font-size: 15px;
    letter-spacing: 3px;
    color: $goldSoft;
    font-weight: 500;
  }
  .live-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: $gold;
    animation: pulse 1.4s infinite;
  }
}

.feed {
  list-style: none;
  overflow-y: auto;
  padding: 8px 0;
  flex: 1;

  li {
    padding: 10px 16px;
    border-bottom: 1px solid rgba(42, 42, 42, 0.6);
  }
}

.feed-top {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 8px;
}

.feed-user {
  font-size: 12.5px;
  color: $text;
  letter-spacing: 0.5px;
}

.feed-amt {
  font-size: 13px;
  color: $goldSoft;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

.feed-bot {
  display: flex;
  justify-content: space-between;
  margin-top: 4px;
  gap: 8px;
}

.feed-lot {
  font-size: 11px;
  color: $textDim;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.feed-time {
  font-size: 11px;
  color: #6a6a6a;
  flex: 0 0 auto;
}

.feed-empty,
.rb-empty {
  color: $textDim;
  font-size: 12px;
  text-align: center;
  padding: 18px;
}

/* ============ 出价弹窗 ============ */
.mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 48px 16px;
  overflow-y: auto;
  z-index: 50;
}

.modal {
  width: 100%;
  max-width: 480px;
  border: 1px solid $line;
  border-radius: 4px;
  background: linear-gradient(160deg, $bg1, $bg2);
  box-shadow: 0 40px 80px -40px rgba(0, 0, 0, 0.9);
}

.modal-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid $line;

  h3 {
    font-family: $serif;
    font-size: 17px;
    letter-spacing: 3px;
    color: $goldSoft;
    font-weight: 500;
  }
}

.x {
  background: transparent;
  border: none;
  color: $textDim;
  font-size: 16px;
  cursor: pointer;

  &:hover { color: $goldSoft; }
}

.modal-body {
  padding: 18px 20px;
}

.lot-summary {
  display: flex;
  align-items: center;
  gap: 14px;
  padding-bottom: 16px;
  border-bottom: 1px solid $line;
}

.lot-icon {
  width: 46px;
  height: 46px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  background: linear-gradient(160deg, $bg2, #0e0e0e);
  border: 1px solid $line;
}

.lot-title {
  font-size: 14px;
  color: $text;
  letter-spacing: 0.5px;
}

.lot-cat {
  font-size: 11px;
  color: $textDim;
  letter-spacing: 1px;
  margin-top: 4px;
}

.price-line {
  display: flex;
  gap: 16px;
  margin: 16px 0;

  > div {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 6px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid $line;
    border-radius: 3px;
    padding: 10px 12px;

    span {
      font-size: 11px;
      letter-spacing: 2px;
      color: $textDim;
    }
    b {
      font-family: $serif;
      font-size: 18px;
      color: $goldSoft;
    }
  }
}

.bid-label {
  font-size: 11px;
  letter-spacing: 2px;
  color: $textDim;
  display: block;
  margin-bottom: 8px;
}

.bid-input {
  display: flex;
  align-items: center;
  gap: 8px;
  border: 1px solid $line;
  border-radius: 3px;
  padding: 0 12px;
  background: var(--bg-0);

  &:focus-within { border-color: $gold; }
  .yen {
    color: $gold;
    font-size: 15px;
  }
  input {
    flex: 1;
    background: transparent;
    border: none;
    outline: none;
    color: $text;
    font-size: 16px;
    padding: 11px 0;
    font-family: var(--sans);
    font-variant-numeric: tabular-nums;
  }
}

.quick {
  display: flex;
  gap: 10px;
  margin-top: 12px;

  button {
    flex: 1;
    padding: 9px;
    background: transparent;
    border: 1px solid $line;
    border-radius: 2px;
    color: $goldSoft;
    font-size: 12px;
    letter-spacing: 1px;
    cursor: pointer;
    transition: border-color 0.2s, background 0.2s;

    &:hover {
      border-color: $gold;
      background: rgba(201, 169, 106, 0.08);
    }
  }
}

.bid-error {
  color: #d98c8c;
  font-size: 12px;
  letter-spacing: 0.5px;
  margin-top: 10px;
}

.records {
  margin-top: 18px;
  border-top: 1px solid $line;
  padding-top: 14px;
}

.records-head {
  font-size: 11px;
  letter-spacing: 2px;
  color: $textDim;
  margin-bottom: 10px;
}

.records-list {
  list-style: none;
  max-height: 180px;
  overflow-y: auto;

  li {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    padding: 8px 0;
    border-bottom: 1px solid rgba(42, 42, 42, 0.5);
    font-size: 12px;
  }
}

.rb-user {
  color: $text;
  letter-spacing: 0.5px;

  em {
    font-style: normal;
    color: $goldSoft;
    font-size: 11px;
    margin-left: 2px;
  }
}

.rb-amt {
  color: $goldSoft;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

.rb-time {
  color: #6a6a6a;
  flex: 0 0 auto;
}

.modal-foot {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 0 20px 20px;
}

.ghost {
  padding: 9px 20px;
  background: transparent;
  border: 1px solid $line;
  border-radius: 2px;
  color: $textDim;
  font-size: 12.5px;
  letter-spacing: 2px;
  cursor: pointer;

  &:hover {
    border-color: $gold;
    color: $goldSoft;
  }
}

.confirm {
  padding: 9px 22px;
  background: linear-gradient(180deg, $goldSoft, $gold);
  border: none;
  border-radius: 2px;
  color: #14110b;
  font-size: 12.5px;
  letter-spacing: 3px;
  font-weight: 500;
  cursor: pointer;
  transition: filter 0.25s;

  &:hover { filter: brightness(1.08); }
}

/* ============ 轻提示 ============ */
.toast {
  position: fixed;
  left: 50%;
  bottom: 40px;
  transform: translateX(-50%);
  z-index: 60;
  background: linear-gradient(160deg, $bg1, $bg2);
  border: 1px solid rgba(201, 169, 106, 0.5);
  color: $goldSoft;
  padding: 12px 22px;
  border-radius: 3px;
  font-size: 13px;
  letter-spacing: 1px;
  box-shadow: 0 20px 40px -20px rgba(0, 0, 0, 0.9);
}

/* ============ 过渡 ============ */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
.toast-enter-active,
.toast-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}
.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translate(-50%, 10px);
}

@keyframes pulse {
  0% { box-shadow: 0 0 0 0 rgba(201, 169, 106, 0.5); }
  70% { box-shadow: 0 0 0 6px rgba(201, 169, 106, 0); }
  100% { box-shadow: 0 0 0 0 rgba(201, 169, 106, 0); }
}

/* ============ 响应式 ============ */
@media (max-width: 1080px) {
  .body {
    flex-direction: column;
  }
  .aside {
    width: 100%;
    flex: none;
    position: static;
    max-height: none;
  }
  .feed {
    max-height: 320px;
  }
}

@media (max-width: 680px) {
  .grid {
    grid-template-columns: 1fr;
  }
  .head h1 {
    font-size: 26px;
  }
  .filter-row {
    flex-direction: column;
    align-items: stretch;
  }
  .right {
    flex-direction: column;
    align-items: stretch;
  }
  .search {
    min-width: 0;
  }
}
</style>
