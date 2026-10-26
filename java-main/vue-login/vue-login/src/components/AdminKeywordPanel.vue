<template>
  <section class="adm-panel">
    <div class="adm-panel-head">
      <div>
        <h2>热门搜索词</h2>
        <p>维护前台首页搜索框下方「热门」标签，热度越高排序越靠前。</p>
      </div>
      <div class="adm-toolbar">
        <button class="adm-btn ghost small" type="button" @click="load">刷新</button>
        <button class="adm-btn small" type="button" @click="openCreate">+ 新增搜索词</button>
      </div>
    </div>

    <div class="adm-panel-body">
      <p v-if="error" class="adm-alert error">{{ error }}</p>
      <p v-if="success" class="adm-alert success">{{ success }}</p>

      <div v-if="loading" class="adm-loading">数据加载中…</div>
      <div v-else-if="!rows.length" class="adm-empty">暂无搜索词，点击右上角「新增搜索词」创建</div>

      <div v-else class="adm-table-wrap">
        <table class="adm-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>搜索词</th>
              <th>热度</th>
              <th>排序</th>
              <th>状态</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="r in rows" :key="r.id">
              <td>{{ r.id }}</td>
              <td>{{ r.keyword }}</td>
              <td>{{ r.heat ?? 0 }}</td>
              <td>{{ r.sortWeight ?? 0 }}</td>
              <td>
                <span class="adm-tag" :class="{ off: r.status !== 1 }">
                  {{ r.status === 1 ? '启用' : '停用' }}
                </span>
              </td>
              <td class="actions">
                <button class="adm-btn ghost small" type="button" @click="openEdit(r)">编辑</button>
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
          <h3>{{ form.id ? '编辑搜索词' : '新增搜索词' }}</h3>
          <button class="adm-close" type="button" @click="editing = false">✕</button>
        </div>
        <div class="adm-modal-body">
          <div class="adm-form">
            <div class="adm-field full">
              <label>搜索词 *</label>
              <input v-model.trim="form.keyword" class="adm-input" placeholder="如：京都赏枫" />
            </div>
            <div class="adm-field">
              <label>热度</label>
              <input v-model.number="form.heat" class="adm-input" type="number" min="0" placeholder="0" />
            </div>
            <div class="adm-field">
              <label>排序权重</label>
              <input v-model.number="form.sortWeight" class="adm-input" type="number" placeholder="0" />
              <span class="hint">数值越大越靠前</span>
            </div>
            <div class="adm-field full">
              <label>状态</label>
              <select v-model.number="form.status" class="adm-select">
                <option :value="1">启用（首页展示）</option>
                <option :value="0">停用（首页隐藏）</option>
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
import { ref, reactive, onMounted } from 'vue'
import { listKeywords, createKeyword, updateKeyword, deleteKeyword } from '../api.js'

const emit = defineEmits(['unauthorized'])

const rows = ref([])
const loading = ref(false)
const saving = ref(false)
const error = ref('')
const success = ref('')
const editing = ref(false)

const emptyForm = () => ({ id: null, keyword: '', heat: 0, sortWeight: 0, status: 1 })
const form = reactive(emptyForm())

async function load() {
  loading.value = true
  error.value = ''
  try {
    rows.value = await listKeywords()
  } catch (e) {
    if (e.unauthorized) return emit('unauthorized')
    error.value = e.message || '搜索词列表加载失败'
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
  Object.assign(form, emptyForm())
  editing.value = true
}

function openEdit(row) {
  error.value = ''
  success.value = ''
  Object.assign(form, emptyForm(), {
    id: row.id,
    keyword: row.keyword || '',
    heat: row.heat ?? 0,
    sortWeight: row.sortWeight ?? 0,
    status: row.status ?? 1
  })
  editing.value = true
}

async function save() {
  if (!form.keyword) {
    error.value = '请填写搜索词'
    return
  }
  saving.value = true
  error.value = ''
  try {
    const body = {
      keyword: form.keyword,
      heat: form.heat || 0,
      sortWeight: form.sortWeight || 0,
      status: form.status
    }
    if (form.id) await updateKeyword(form.id, { ...body, id: form.id })
    else await createKeyword(body)
    success.value = form.id ? '搜索词已更新' : '搜索词已创建'
    editing.value = false
    await load()
  } catch (e) {
    guard(e)
  } finally {
    saving.value = false
  }
}

async function remove(row) {
  if (!confirm(`确定删除搜索词「${row.keyword}」？`)) return
  error.value = ''
  success.value = ''
  try {
    await deleteKeyword(row.id)
    success.value = `搜索词「${row.keyword}」已删除`
    await load()
  } catch (e) {
    guard(e)
  }
}

onMounted(load)
</script>
