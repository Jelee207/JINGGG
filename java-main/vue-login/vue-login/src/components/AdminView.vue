<template>
  <div class="adm-app">
    <!-- ================= 顶部导航 ================= -->
    <header class="adm-head">
      <div class="adm-brand">
        AURELIA CLUB
        <small>后台管理系统 · ADMIN CONSOLE</small>
      </div>

      <div class="adm-head-right">
        <span class="adm-user">当前管理员：<b>{{ username }}</b></span>
        <button class="adm-btn ghost small" type="button" @click="emit('back')">前台首页</button>
        <button class="adm-btn ghost small" type="button" @click="emit('logout')">退出登录</button>
      </div>
    </header>

    <!-- ================= 主体 ================= -->
    <div class="adm-body">
      <aside class="adm-side">
        <div class="adm-side-title">首页数据管理</div>
        <nav class="adm-menu">
          <a
            v-for="item in menus"
            :key="item.key"
            href="#"
            :class="{ active: active === item.key }"
            @click.prevent="active = item.key"
          >{{ item.label }}</a>
        </nav>
      </aside>

      <main class="adm-main">
        <!-- 数据概览 -->
        <section v-if="active === 'overview'" class="adm-panel">
          <div class="adm-panel-head">
            <h2>数据概览</h2>
            <button class="adm-btn ghost small" type="button" @click="loadOverview">
              刷新数据
            </button>
          </div>
          <div class="adm-panel-body">
            <p v-if="loadError" class="adm-alert error">{{ loadError }}</p>

            <div class="adm-stats">
              <div class="adm-stat">
                <span>分类入口总数</span>
                <b>{{ overview.categoryCount ?? '-' }}</b>
                <i>启用 {{ overview.categoryOnCount ?? 0 }} 项</i>
              </div>
              <div class="adm-stat">
                <span>精选内容总数</span>
                <b>{{ overview.postCount ?? '-' }}</b>
                <i>已发布 {{ overview.postOnCount ?? 0 }} 篇</i>
              </div>
              <div class="adm-stat">
                <span>草稿内容</span>
                <b>{{ overview.postDraftCount ?? '-' }}</b>
                <i>首页暂不展示</i>
              </div>
              <div class="adm-stat">
                <span>热门搜索词</span>
                <b>{{ overview.keywordCount ?? '-' }}</b>
                <i>启用 {{ overview.keywordOnCount ?? 0 }} 个</i>
              </div>
            </div>

            <div class="quick">
              <div class="quick-title">管理入口</div>
              <div class="quick-grid">
                <a href="#" @click.prevent="active = 'categories'">分类快捷入口 → 首页六个分类图标与文案</a>
                <a href="#" @click.prevent="active = 'posts'">编辑精选内容 → 首页内容流与搜索结果</a>
                <a href="#" @click.prevent="active = 'keywords'">热门搜索词 → 首页「热门」标签云</a>
              </div>
            </div>

            <p class="note">
              提示：此处的所有改动即时生效，前台首页（/api/home/feed）会直接读取这些数据。
            </p>
          </div>
        </section>

        <AdminCategoryPanel v-else-if="active === 'categories'" @unauthorized="onUnauthorized" />
        <AdminPostPanel v-else-if="active === 'posts'" @unauthorized="onUnauthorized" />
        <AdminKeywordPanel v-else-if="active === 'keywords'" @unauthorized="onUnauthorized" />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getAdminOverview } from '../api.js'
import AdminCategoryPanel from './AdminCategoryPanel.vue'
import AdminPostPanel from './AdminPostPanel.vue'
import AdminKeywordPanel from './AdminKeywordPanel.vue'

defineProps({
  username: { type: String, default: '' }
})
const emit = defineEmits(['logout', 'back'])

const menus = [
  { key: 'overview', label: '数据概览' },
  { key: 'categories', label: '分类入口管理' },
  { key: 'posts', label: '精选内容管理' },
  { key: 'keywords', label: '热门搜索词' }
]

const active = ref('overview')
const overview = reactive({})
const loadError = ref('')

async function loadOverview() {
  loadError.value = ''
  try {
    Object.assign(overview, await getAdminOverview())
  } catch (e) {
    if (e.unauthorized) return onUnauthorized()
    loadError.value = e.message || '概览数据加载失败'
  }
}

function onUnauthorized() {
  emit('logout')
}

onMounted(loadOverview)
</script>

<style scoped>
.quick {
  margin-top: 26px;
  border-top: 1px solid var(--line);
  padding-top: 20px;
}

.quick-title {
  font-size: 11px;
  letter-spacing: 3px;
  color: var(--text-dim);
  margin-bottom: 12px;
}

.quick-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.quick-grid a {
  display: block;
  padding: 14px 16px;
  border: 1px solid var(--line);
  border-radius: 3px;
  font-size: 12.5px;
  line-height: 1.7;
  letter-spacing: 0.5px;
  color: var(--text-dim);
  text-decoration: none;
  transition: border-color 0.25s ease, color 0.25s ease, transform 0.25s ease;
}

.quick-grid a:hover {
  border-color: var(--gold);
  color: var(--gold-soft);
  transform: translateY(-2px);
}

.note {
  margin-top: 24px;
  font-size: 11.5px;
  letter-spacing: 1px;
  color: var(--text-dim);
}

@media (max-width: 900px) {
  .quick-grid {
    grid-template-columns: 1fr;
  }
}
</style>
