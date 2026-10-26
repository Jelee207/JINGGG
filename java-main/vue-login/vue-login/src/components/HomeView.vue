<template>
  <div class="home">
    <!-- ================= 顶部导航栏（复用 TopNav） ================= -->
    <TopNav
      :username="username"
      :permission="permission"
      active="home"
      @nav="(k) => emit('nav', k)"
      @logout="onLogout"
      @admin="onAdmin"
    />

    <main class="main">
      <!-- ================= 搜索区（Hero） ================= -->
      <section class="hero">
        <h1 class="greeting">{{ greeting }}，{{ username || '尊贵的会员' }}</h1>
        <p class="hero-sub">探索专属于您的礼遇与灵感</p>

        <form class="search" @submit.prevent="onSearch">
          <span class="search-icon">⌕</span>
          <input
            v-model.trim="keyword"
            type="text"
            placeholder="搜索目的地、餐厅、展览、活动…"
            aria-label="站内搜索"
          />
          <button type="submit">搜 索</button>
        </form>

        <div class="hots">
          <span class="hots-label">热门</span>
          <a
            v-for="h in hotKeywords"
            :key="h"
            href="#"
            @click.prevent="quickSearch(h)"
          >{{ h }}</a>
        </div>
      </section>

      <!-- ================= 会员信息条 ================= -->
      <section class="member">
        <div class="member-item">
          <span class="member-label">会员等级</span>
          <span class="member-value gold">金卡会员 · GOLD</span>
        </div>
        <div class="member-divider"></div>
        <div class="member-item">
          <span class="member-label">当前积分</span>
          <span class="member-value">12,480</span>
        </div>
        <div class="member-divider"></div>
        <div class="member-item">
          <span class="member-label">会员有效期</span>
          <span class="member-value">2027-12-31</span>
        </div>
        <div class="member-divider"></div>
        <div class="member-item">
          <span class="member-label">待使用礼遇</span>
          <span class="member-value">3 项</span>
        </div>
      </section>

      <!-- ================= 分类快捷入口 ================= -->
      <section class="cats">
        <a
          v-for="c in categories"
          :key="c.name"
          href="#"
          class="cat"
          @click.prevent="quickSearch(c.keyword || c.name)"
        >
          <span class="cat-icon">{{ c.icon }}</span>
          <span class="cat-name">{{ c.name }}</span>
          <span class="cat-desc">{{ c.desc }}</span>
        </a>
      </section>

      <!-- ================= 编辑精选内容流 ================= -->
      <section class="section">
        <div class="section-head">
          <h2>编辑精选</h2>
          <a v-if="searched" href="#" class="clear" @click.prevent="clearSearch">
            清除搜索“{{ searched }}” ✕
          </a>
          <a v-else href="#" class="more" @click.prevent="onNav('discover')">查看全部 →</a>
        </div>

        <div class="grid">
          <article v-for="p in results" :key="p.id" class="post" @click="onNav('detail')">
            <div class="post-meta">
              <span class="post-tag">{{ p.category }}</span>
              <span class="post-date">{{ p.date }}</span>
            </div>
            <h3 class="post-title">{{ p.title }}</h3>
            <p class="post-desc">{{ p.desc }}</p>
            <span class="post-more">阅读全文 →</span>
          </article>
        </div>

        <p v-if="!results.length" class="empty">
          未找到与“{{ searched }}”相关的内容，换个关键词试试
        </p>
      </section>
    </main>

    <!-- ================= 页脚 ================= -->
    <footer class="foot">
      <div class="foot-brand">AURELIA CLUB</div>
      <div class="foot-copy">© 2026 AURELIA · 会员俱乐部 · 前端演示页面，后端接口预留中</div>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { getHomeFeed, searchAll } from '../api.js'
import TopNav from './TopNav.vue'

const props = defineProps({
  username: { type: String, default: '' },
  // 权限：0 管理员，1 默认会员；仅管理员（0）可见后台管理系统入口
  permission: { type: Number, default: 1 }
})
const emit = defineEmits(['logout', 'admin', 'nav'])

/* ---------------- 导航栏 ---------------- */
const menuOpen = ref(false)
const activeNav = ref('home')
const navItems = [
  { key: 'home', label: '首页' },
  { key: 'auction', label: '竞拍' }
]

const initial = computed(() => {
  const n = props.username || '会员'
  return n.charAt(0).toUpperCase()
})

const greeting = computed(() => {
  const h = new Date().getHours()
  if (h < 6) return '夜深了'
  if (h < 12) return '早上好'
  if (h < 14) return '午安'
  if (h < 18) return '下午好'
  return '晚上好'
})

function onNav(key) {
  // TODO: 其余页面暂未创建，先仅做占位提示
  activeNav.value = key
  menuOpen.value = false
}

/* 跳转后台管理系统（见 App.vue -> goAdminLogin） */
function onAdmin() {
  menuOpen.value = false
  emit('admin')
}

/* ---------------- 搜索栏 ---------------- */
const keyword = ref('')
const searched = ref('')
const hotKeywords = ref(['京都赏枫', '米其林晚宴', '私享游艇', '艺术沙龙'])

async function onSearch() {
  searched.value = keyword.value
  // 预留后端接口：后端就绪后走 GET /api/search，见 src/api.js -> searchAll
  await searchAll(keyword.value) // 后端未启动时返回 null，页面用本地过滤结果
}

function quickSearch(k) {
  keyword.value = k
  onSearch()
}

function clearSearch() {
  keyword.value = ''
  searched.value = ''
}

const results = computed(() => {
  if (!searched.value) return posts.value
  const k = searched.value.toLowerCase()
  return posts.value.filter(
    (p) =>
      p.title.toLowerCase().includes(k) ||
      p.desc.toLowerCase().includes(k) ||
      p.category.toLowerCase().includes(k)
  )
})

/* ---------------- 首页数据（本地演示，后端就绪后由接口覆盖） ---------------- */
const categories = ref([
  { icon: '❖', name: '私人礼遇', desc: '管家式定制服务' },
  { icon: '◈', name: '餐饮甄选', desc: '米其林主厨餐桌' },
  { icon: '✦', name: '旅行栖居', desc: '全球奢华酒店礼遇' },
  { icon: '◆', name: '艺术文化', desc: '私人画廊与沙龙' },
  { icon: '❋', name: '健康生活', desc: '高端康养与 SPA' },
  { icon: '✧', name: '会员活动', desc: '专属线下聚会' }
])

const posts = ref([
  {
    id: 1,
    category: '旅行栖居',
    date: '10-12',
    title: '京都 · 枫叶季私邸栖居七日',
    desc: '入住百年町家改造私邸，随茶道师体验一期一会的秋日茶席，专车漫游东山暮色。'
  },
  {
    id: 2,
    category: '餐饮甄选',
    date: '10-10',
    title: '秋暮主厨餐桌 · 八道式品鉴晚宴',
    desc: '米其林二星主厨应季菜单，侍酒师配对勃艮第名家年份，仅设十二席。'
  },
  {
    id: 3,
    category: '艺术文化',
    date: '10-08',
    title: '私人画廊之夜：当代水墨新声',
    desc: '闭馆专场导览，与艺术家对谈，率先预订限量版画收藏席位。'
  },
  {
    id: 4,
    category: '会员活动',
    date: '10-05',
    title: '黄浦江畔 · 私享游艇酒会',
    desc: '落日巡游与香槟品鉴，结识同席会员，限额三十位，凭会员码报名。'
  },
  {
    id: 5,
    category: '健康生活',
    date: '10-02',
    title: '山间疗愈 · 森林冥想康养营',
    desc: '三日两夜山居静修，颂钵疗愈与有机轻食，为身心按下暂停键。'
  },
  {
    id: 6,
    category: '私人礼遇',
    date: '09-28',
    title: '管家服务升级：全球行程一站托管',
    desc: '签证、专车、餐厅与活动预订全程代办，您的专属礼宾团队已就位。'
  }
])

onMounted(async () => {
  // 数据源即后台管理系统维护内容：GET /api/home/feed，见 src/api.js -> getHomeFeed
  const feed = await getHomeFeed()
  if (feed) {
    if (Array.isArray(feed.categories) && feed.categories.length) {
      categories.value = feed.categories
    }
    if (Array.isArray(feed.posts) && feed.posts.length) {
      posts.value = feed.posts
    }
    if (Array.isArray(feed.hotKeywords) && feed.hotKeywords.length) {
      hotKeywords.value = feed.hotKeywords
    }
  }
})

function onLogout() {
  emit('logout')
}
</script>

<style scoped>
/* ============ 整体布局：导航栏 + 主体 + 页脚 ============ */
.home {
  width: 100%;
  max-width: 1180px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  min-height: calc(100vh - 48px);
}

.main {
  flex: 1;
}

/* ============ 顶部导航栏 ============ */
.nav {
  position: sticky;
  top: 0;
  z-index: 10;
  background: rgba(10, 10, 10, 0.88);
  backdrop-filter: blur(10px);
}

.nav-inner {
  display: flex;
  align-items: center;
  gap: 40px;
  padding: 18px 8px 16px;
}

.nav-line {
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--gold) 30%, var(--gold) 70%, transparent);
  opacity: 0.45;
}

.logo {
  font-family: var(--serif);
  font-size: 22px;
  letter-spacing: 5px;
  color: var(--gold-soft);
  text-decoration: none;
  font-weight: 500;
  white-space: nowrap;
}

.logo span {
  font-size: 10px;
  letter-spacing: 3px;
  color: var(--text-dim);
  margin-left: 8px;
  vertical-align: middle;
}

.links {
  display: flex;
  gap: 30px;
  flex: 1;
  justify-content: flex-start;
  flex-wrap: wrap;
}

.links a {
  font-size: 13px;
  letter-spacing: 2px;
  color: var(--text-dim);
  text-decoration: none;
  padding-bottom: 4px;
  border-bottom: 1px solid transparent;
  transition: color 0.25s ease, border-color 0.25s ease;
}

.links a:hover {
  color: var(--text);
}

.links a.active {
  color: var(--gold-soft);
  border-bottom-color: var(--gold);
}

/* 后台管理系统入口按钮 */
.admin-entry {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 7px 16px;
  background: transparent;
  border: 1px solid var(--gold);
  border-radius: 2px;
  color: var(--gold-soft);
  font-family: var(--sans);
  font-size: 12.5px;
  letter-spacing: 2px;
  cursor: pointer;
  white-space: nowrap;
  transition: background 0.25s ease, color 0.25s ease, transform 0.1s ease;
}

.admin-entry .gear {
  font-size: 11px;
  color: var(--gold);
}

.admin-entry:hover {
  background: rgba(201, 169, 106, 0.1);
  color: var(--gold);
}

.admin-entry:active {
  transform: translateY(1px);
}

/* 用户菜单 */
.user {
  position: relative;
}

.user-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  background: transparent;
  border: 1px solid var(--line);
  border-radius: 2px;
  padding: 7px 14px 7px 8px;
  cursor: pointer;
  color: var(--text);
  font-family: var(--sans);
  transition: border-color 0.25s ease;
}

.user-btn:hover {
  border-color: var(--gold);
}

.avatar {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: linear-gradient(160deg, var(--gold-soft), var(--gold));
  color: #14110b;
  font-size: 13px;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.user .name {
  font-size: 13px;
  letter-spacing: 1px;
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user .caret {
  font-size: 10px;
  color: var(--text-dim);
}

.menu {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  min-width: 150px;
  background: linear-gradient(160deg, var(--bg-1), var(--bg-2));
  border: 1px solid var(--line);
  border-radius: 4px;
  padding: 8px 0;
  box-shadow: 0 30px 60px -30px rgba(0, 0, 0, 0.9);
}

.menu a {
  display: block;
  padding: 10px 18px;
  font-size: 12.5px;
  letter-spacing: 1px;
  color: var(--text-dim);
  text-decoration: none;
  transition: color 0.2s ease, background 0.2s ease;
}

.menu a:hover {
  color: var(--gold-soft);
  background: rgba(201, 169, 106, 0.06);
}

.menu a.danger:hover {
  color: #d98c8c;
}

/* 下拉淡入动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.18s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* ============ 搜索区（Hero） ============ */
.hero {
  text-align: center;
  padding: 72px 16px 8px;
}

.greeting {
  font-family: var(--serif);
  font-size: 34px;
  font-weight: 500;
  letter-spacing: 3px;
  color: var(--text);
}

.hero-sub {
  margin-top: 12px;
  font-size: 13px;
  letter-spacing: 4px;
  color: var(--text-dim);
}

.search {
  margin: 40px auto 0;
  max-width: 620px;
  display: flex;
  align-items: center;
  background: linear-gradient(160deg, var(--bg-1), var(--bg-2));
  border: 1px solid var(--line);
  border-radius: 4px;
  padding: 6px 6px 6px 18px;
  transition: border-color 0.3s ease;
}

.search:focus-within {
  border-color: var(--gold);
}

.search-icon {
  color: var(--gold);
  font-size: 18px;
  margin-right: 12px;
  user-select: none;
}

.search input {
  flex: 1;
  background: transparent;
  border: none;
  outline: none;
  color: var(--text);
  font-size: 14.5px;
  letter-spacing: 1px;
  padding: 10px 0;
  font-family: var(--sans);
  min-width: 0;
}

.search input::placeholder {
  color: #555;
}

.search button {
  padding: 11px 26px;
  background: linear-gradient(180deg, var(--gold-soft), var(--gold));
  color: #14110b;
  border: none;
  border-radius: 2px;
  font-size: 13px;
  letter-spacing: 3px;
  font-weight: 500;
  cursor: pointer;
  transition: filter 0.25s ease, transform 0.1s ease;
  white-space: nowrap;
}

.search button:hover {
  filter: brightness(1.08);
}

.search button:active {
  transform: translateY(1px);
}

.hots {
  margin-top: 18px;
  font-size: 12px;
  letter-spacing: 1px;
  color: var(--text-dim);
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.hots-label {
  letter-spacing: 3px;
  padding-right: 2px;
}

.hots a {
  color: var(--text-dim);
  text-decoration: none;
  transition: color 0.25s ease;
}

.hots a:hover {
  color: var(--gold-soft);
}

/* ============ 会员信息条 ============ */
.member {
  margin: 48px 0 0;
  display: flex;
  align-items: stretch;
  justify-content: center;
  gap: 0;
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  padding: 22px 0;
  flex-wrap: wrap;
  row-gap: 16px;
}

.member-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 0 44px;
}

.member-label {
  font-size: 11px;
  letter-spacing: 3px;
  color: var(--text-dim);
  text-transform: uppercase;
}

.member-value {
  font-size: 15px;
  letter-spacing: 1px;
  color: var(--text);
}

.member-value.gold {
  color: var(--gold-soft);
  font-weight: 600;
}

.member-divider {
  width: 1px;
  background: var(--line);
}

/* ============ 分类快捷入口 ============ */
.cats {
  margin-top: 48px;
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 16px;
}

.cat {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 26px 12px;
  background: linear-gradient(160deg, var(--bg-1), var(--bg-2));
  border: 1px solid var(--line);
  border-radius: 4px;
  text-decoration: none;
  position: relative;
  overflow: hidden;
  transition: border-color 0.3s ease, transform 0.25s ease;
}

.cat::before {
  content: "";
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 40px;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--gold), transparent);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.cat:hover {
  border-color: var(--gold);
  transform: translateY(-3px);
}

.cat:hover::before {
  opacity: 1;
}

.cat-icon {
  font-size: 20px;
  color: var(--gold);
}

.cat-name {
  font-size: 13.5px;
  letter-spacing: 2px;
  color: var(--text);
}

.cat-desc {
  font-size: 11px;
  letter-spacing: 1px;
  color: var(--text-dim);
}

/* ============ 编辑精选内容流 ============ */
.section {
  margin-top: 56px;
}

.section-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 24px;
}

.section-head h2 {
  font-family: var(--serif);
  font-size: 22px;
  font-weight: 500;
  letter-spacing: 4px;
  color: var(--gold-soft);
}

.section-head .more,
.section-head .clear {
  font-size: 12px;
  letter-spacing: 1px;
  color: var(--text-dim);
  text-decoration: none;
  transition: color 0.25s ease;
}

.section-head .more:hover,
.section-head .clear:hover {
  color: var(--gold-soft);
}

.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
}

.post {
  background: linear-gradient(160deg, var(--bg-1), var(--bg-2));
  border: 1px solid var(--line);
  border-radius: 4px;
  padding: 26px 26px 24px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  transition: border-color 0.3s ease, transform 0.25s ease;
}

.post:hover {
  border-color: var(--gold);
  transform: translateY(-3px);
}

.post-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}

.post-tag {
  font-size: 10.5px;
  letter-spacing: 2px;
  color: var(--gold-soft);
  border: 1px solid rgba(201, 169, 106, 0.4);
  padding: 3px 10px;
  border-radius: 2px;
}

.post-date {
  font-size: 11.5px;
  letter-spacing: 1px;
  color: var(--text-dim);
}

.post-title {
  font-size: 16.5px;
  letter-spacing: 1px;
  color: var(--text);
  font-weight: 600;
  line-height: 1.5;
}

.post-desc {
  margin-top: 10px;
  flex: 1;
  font-size: 13px;
  line-height: 1.9;
  color: var(--text-dim);
  letter-spacing: 0.5px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.post-more {
  margin-top: 18px;
  font-size: 12px;
  letter-spacing: 2px;
  color: var(--gold);
  opacity: 0;
  transform: translateY(2px);
  transition: opacity 0.25s ease, transform 0.25s ease;
}

.post:hover .post-more {
  opacity: 1;
  transform: none;
}

.empty {
  text-align: center;
  padding: 56px 0;
  font-size: 13px;
  letter-spacing: 2px;
  color: var(--text-dim);
}

/* ============ 页脚 ============ */
.foot {
  margin-top: 72px;
  border-top: 1px solid var(--line);
  padding: 32px 0 8px;
  text-align: center;
}

.foot-brand {
  font-family: var(--serif);
  font-size: 15px;
  letter-spacing: 6px;
  color: var(--gold-soft);
}

.foot-copy {
  margin-top: 12px;
  font-size: 11.5px;
  letter-spacing: 1px;
  color: var(--text-dim);
}

/* ============ 响应式 ============ */
@media (max-width: 960px) {
  .cats {
    grid-template-columns: repeat(3, 1fr);
  }
  .grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .links {
    gap: 18px;
  }
}

@media (max-width: 640px) {
  .nav-inner {
    flex-wrap: wrap;
    gap: 16px;
  }
  .links {
    order: 3;
    width: 100%;
    justify-content: flex-start;
  }
  .cats {
    grid-template-columns: repeat(2, 1fr);
  }
  .grid {
    grid-template-columns: 1fr;
  }
  .member-divider {
    display: none;
  }
  .greeting {
    font-size: 26px;
  }
}
</style>
