<template>
  <section class="adm-panel">
    <div class="adm-panel-head">
      <div>
        <h2>精选内容管理</h2>
        <p>维护前台首页「编辑精选」内容流与站内搜索结果，品牌后台改动即时同步到首页。</p>
      </div>
      <div class="adm-toolbar">
        <button class="adm-btn ghost small" type="button" @click="load">刷新</button>
        <button class="adm-btn small" type="button" @click="openCreate">+ 新增内容</button>
      </div>
    </div>

    <div class="adm-panel-body">
      <p v-if="error" class="adm-alert error">{{ error }}</p>
      <p v-if="success" class="adm-alert success">{{ success }}</p>

      <div class="adm-toolbar filter">
        <input
          v-model.trim="filters.keyword"
          class="adm-input"
          placeholder="按标题搜索"
          @keyup.enter="load"
        />
        <select v-model="filters.category" class="adm-select" @change="load">
          <option value="">全部分类</option>
          <option v-for="c in categoryNames" :key="c" :value="c">{{ c }}</option>
        </select>
        <button class="adm-btn ghost small" type="button" @click="load">查询</button>
      </div>

      <div v-if="loading" class="adm-loading">数据加载中…</div>
      <div v-else-if="!rows.length" class="adm-empty">暂无内容，点击右上角「新增内容」创建</div>

      <div v-else class="adm-table-wrap">
        <table class="adm-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>标题</th>
              <th>分类</th>
              <th>城市</th>
              <th>发布时间</th>
              <th>阅读</th>
              <th>排序</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="r in rows" :key="r.id">
              <td>{{ r.id }}</td>
              <td>
                <div class="title">{{ r.title }}</div>
                <div class="summary">{{ r.summary }}</div>
              </td>
              <td>{{ r.category || '—' }}</td>
              <td>{{ r.city || '—' }}</td>
              <td>{{ formatDate(r.publishAt) }}</td>
              <td>{{ r.readCount ?? 0 }}</td>
              <td>{{ r.sortWeight ?? 0 }}</td>
              <td>
                <span class="adm-tag" :class="{ off: r.status !== 1 }">
                  {{ r.status === 1 ? '已发布' : '草稿' }}
                </span>
              </td>
              <td class="actions">
                <button class="adm-btn ghost small" type="button" @click="openEdit(r)">编辑</button>
                <button
                  class="adm-btn ghost small"
                  type="button"
                  @click="toggleStatus(r)"
                >{{ r.status === 1 ? '转草稿' : '发布' }}</button>
                <button class="adm-btn danger small" type="button" @click="remove(r)">删除</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- 新增 / 编辑弹窗 -->
    <div v-if="editing" class="adm-mask" @click.self="editing = false">
      <div class="adm-modal">
        <div class="adm-modal-head">
          <h3>{{ form.id ? '编辑内容' : '新增内容' }}</h3>
          <button class="adm-close" type="button" @click="editing = false">✕</button>
        </div>
        <div class="adm-modal-body">
          <div class="adm-form">
            <div class="adm-field full">
              <label>标题 *</label>
              <input v-model.trim="form.title" class="adm-input" placeholder="如：京都 · 枫叶季私邸栖居七日" />
            </div>
            <div class="adm-field full">
              <label>摘要（首页卡片展示）</label>
              <textarea v-model.trim="form.summary" class="adm-textarea" rows="2" placeholder="两句话讲清楚亮点" />
            </div>
            <div class="adm-field full">
              <label>正文</label>
              <textarea v-model="form.content" class="adm-textarea" rows="5" placeholder="完整内容，可留空" />
            </div>
            <div class="adm-field">
              <label>分类</label>
              <input v-model.trim="form.category" class="adm-input" list="post-category-list" placeholder="如：旅行栖居" />
              <datalist id="post-category-list">
                <option v-for="c in categoryNames" :key="c" :value="c"></option>
              </datalist>
            </div>
            <div class="adm-field">
              <label>城市 / 目的地</label>
              <input v-model.trim="form.city" class="adm-input" placeholder="如：京都" />
            </div>
            <div class="adm-field">
              <label>作者 / 责编</label>
              <input v-model.trim="form.author" class="adm-input" placeholder="如：编辑部 · 叶" />
            </div>
            <div class="adm-field">
              <label>发布时间</label>
              <input v-model="form.publishAt" class="adm-input" type="datetime-local" />
            </div>
            <div class="adm-field">
              <label>封面图 URL</label>
              <input v-model.trim="form.cover" class="adm-input" placeholder="留空则首页用图标占位" />
            </div>
            <div class="adm-field">
              <label>标签（逗号分隔）</label>
              <input v-model.trim="form.tags" class="adm-input" placeholder="如：旅行,限定,秋季" />
            </div>
            <div class="adm-field">
              <label>阅读数</label>
              <input v-model.number="form.readCount" class="adm-input" type="number" min="0" />
            </div>
            <div class="adm-field">
              <label>点赞数</label>
              <input v-model.number="form.likeCount" class="adm-input" type="number" min="0" />
            </div>
            <div class="adm-field">
              <label>排序权重</label>
              <input v-model.number="form.sortWeight" class="adm-input" type="number" />
              <span class="hint">数值越大越靠前</span>
            </div>
            <div class="adm-field">
              <label>状态</label>
              <select v-model.number="form.status" class="adm-select">
                <option :value="1">已发布（首页展示）</option>
                <option :value="0">草稿（首页隐藏）</option>
              </select>
            </div>
          </div>
        </div>
        <div class="adm-modal-foot">
          <button class="adm-btn ghost" type="button" @click="editing = false">取消</button>
          <button class="adm-btn" type="button" :disabled="saving" @click="save">
            {{ saving ? '保存中…' : '保存' }}
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { listPosts, createPost, updatePost, deletePost } from '../api.js'

const emit = defineEmits(['unauthorized'])

const rows = ref([])
const loading = ref(false)
const saving = ref(false)
const error = ref('')
const success = ref('')
const editing = ref(false)
const filters = reactive({ keyword: '', category: '' })

// 分类下拉来源：后台分类表的值，供表单快速选择
const categoryNames = computed(() => {
  const set = new Set()
  rows.value.forEach((r) => r.category && set.add(r.category))
  return [...set]
})

const emptyForm = () => ({
  id: null,
  title: '',
  summary: '',
  content: '',
  category: '',
  cover: '',
  author: '',
  city: '',
  tags: '',
  readCount: 0,
  likeCount: 0,
  publishAt: '',
  sortWeight: 0,
  status: 1
})
const form = reactive(emptyForm())

function formatDate(v) {
  if (!v) return '—'
  return String(v).replace('T', ' ').slice(0, 16)
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    rows.value = await listPosts({ keyword: filters.keyword, category: filters.category })
  } catch (e) {
    if (e.unauthorized) return emit('unauthorized')
    error.value = e.message || '内容列表加载失败'
  } finally {
    loading.value = false
  }
}

function guard(e) {
  if (e.unauthorized) {
    emit('unauthorized')
    return true
  }
  error.value = e.message || '操作失败'
  return false
}

function openCreate() {
  error.value = ''
  success.value = ''
  Object.assign(form, emptyForm(), { publishAt: nowLocal() })
  editing.value = true
}

function openEdit(row) {
  error.value = ''
  success.value = ''
  Object.assign(form, emptyForm(), {
    id: row.id,
    title: row.title || '',
    summary: row.summary || '',
    content: row.content || '',
    category: row.category || '',
    cover: row.cover || '',
    author: row.author || '',
    city: row.city || '',
    tags: row.tags || '',
    readCount: row.readCount ?? 0,
    likeCount: row.likeCount ?? 0,
    publishAt: row.publishAt ? String(row.publishAt).slice(0, 16) : '',
    sortWeight: row.sortWeight ?? 0,
    status: row.status ?? 1
  })
  editing.value = true
}

function nowLocal() {
  const d = new Date()
  const pad = (n) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

async function save() {
  if (!form.title) {
    error.value = '请填写标题'
    return
  }
  saving.value = true
  error.value = ''
  try {
    const body = {
      title: form.title,
      summary: form.summary,
      content: form.content,
      category: form.category,
      cover: form.cover,
      author: form.author,
      city: form.city,
      tags: form.tags,
      readCount: form.readCount || 0,
      likeCount: form.likeCount || 0,
      publishAt: form.publishAt ? `${form.publishAt}:00` : null,
      sortWeight: form.sortWeight || 0,
      status: form.status
    }
    if (form.id) await updatePost(form.id, { ...body, id: form.id })
    else await createPost(body)
    success.value = form.id ? '内容已更新' : '内容已创建'
    editing.value = false
    await load()
  } catch (e) {
    guard(e)
  } finally {
    saving.value = false
  }
}

async function toggleStatus(row) {
  const next = row.status === 1 ? 0 : 1
  error.value = ''
  success.value = ''
  try {
    await updatePost(row.id, { id: row.id, status: next })
    success.value = next === 1 ? '已发布到首页' : '已转为草稿'
    await load()
  } catch (e) {
    guard(e)
  }
}

async function remove(row) {
  if (!confirm(`确定删除「${row.title}」？删除后不可恢复。`)) return
  error.value = ''
  success.value = ''
  try {
    await deletePost(row.id)
    success.value = `内容「${row.title}」已删除`
    await load()
  } catch (e) {
    guard(e)
  }
}

onMounted(load)
</script>

<style scoped>
.filter {
  margin-bottom: 16px;
}

.title {
  color: var(--text);
  max-width: 320px;
}

.summary {
  margin-top: 4px;
  font-size: 11.5px;
  line-height: 1.6;
  color: var(--text-dim);
  max-width: 320px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
