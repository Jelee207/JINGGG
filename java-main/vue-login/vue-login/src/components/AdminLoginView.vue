<template>
  <main class="card">
    <div class="brand">
      <div class="mark">AURELIA<span>CLUB</span></div>
      <div class="sub">后台管理系统 · Admin Console</div>
    </div>

    <form @submit.prevent="handleSubmit" novalidate>
      <div class="field" :class="{ 'has-error': errors.username }">
        <label for="admin-username">管理员账号</label>
        <input
          id="admin-username"
          v-model.trim="form.username"
          type="text"
          placeholder="请输入管理员账号"
          autocomplete="username"
          :aria-invalid="!!errors.username"
          @input="errors.username = ''"
        />
        <span v-if="errors.username" class="error">{{ errors.username }}</span>
      </div>

      <div class="field" :class="{ 'has-error': errors.password }">
        <label for="admin-password">密码</label>
        <input
          id="admin-password"
          v-model="form.password"
          type="password"
          placeholder="请输入密码"
          autocomplete="current-password"
          :aria-invalid="!!errors.password"
          @input="errors.password = ''"
          @keyup.enter="handleSubmit"
        />
        <span v-if="errors.password" class="error">{{ errors.password }}</span>
      </div>

      <button class="btn" type="submit" :disabled="loading">
        {{ loading ? '登 录 中…' : '登 录 后 台' }}
      </button>

      <p v-if="message" class="msg" :class="message.type">{{ message.text }}</p>
    </form>

    <div class="tip">
      <span class="tip-title">管理员登录</span>
      <span class="tip-body">仅管理员可进入，本页不提供注册；忘记密码请联系超级管理员重置。</span>
    </div>

    <div class="foot">
      <a href="#" @click.prevent="emit('back')">← 返回前台首页</a>
    </div>
  </main>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { adminLogin } from '../api.js'

const emit = defineEmits(['authenticated', 'back'])

const form = reactive({ username: '', password: '' })
const errors = reactive({ username: '', password: '' })
const loading = ref(false)
const message = ref(null) // { type: 'success' | 'error', text: string }

function validate() {
  errors.username = form.username ? '' : '请输入管理员账号'
  errors.password = form.password ? '' : '请输入密码'
  return !errors.username && !errors.password
}

async function handleSubmit() {
  message.value = null
  if (!validate()) return

  loading.value = true
  try {
    // 后台登录接口：POST /api/admin/login，无验证码，见 src/api.js -> adminLogin
    await adminLogin(form.username, form.password)
    message.value = { type: 'success', text: '登录成功，正在进入后台…' }
    emit('authenticated')
  } catch (e) {
    message.value = { type: 'error', text: e.message || '登录失败，请重试' }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.card {
  width: 100%;
  max-width: 420px;
  background: linear-gradient(160deg, var(--bg-1), var(--bg-2));
  border: 1px solid var(--line);
  border-radius: 4px;
  padding: 52px 44px 36px;
  position: relative;
  box-shadow:
    0 1px 0 rgba(255, 255, 255, 0.04) inset,
    0 40px 80px -40px rgba(0, 0, 0, 0.9);
}

.card::before {
  content: "";
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 64px;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--gold), transparent);
}

.brand {
  text-align: center;
  margin-bottom: 38px;
}

.brand .mark {
  font-family: var(--serif);
  font-size: 26px;
  letter-spacing: 5px;
  color: var(--gold-soft);
  font-weight: 500;
}

.brand .mark span {
  font-size: 10px;
  letter-spacing: 3px;
  color: var(--text-dim);
  margin-left: 6px;
  vertical-align: middle;
}

.brand .sub {
  margin-top: 10px;
  font-size: 11.5px;
  letter-spacing: 3px;
  color: var(--text-dim);
}

.field {
  margin-bottom: 24px;
}

.field label {
  display: block;
  font-size: 12px;
  letter-spacing: 2px;
  color: var(--text-dim);
  margin-bottom: 9px;
}

.field input {
  width: 100%;
  background: transparent;
  border: none;
  border-bottom: 1px solid var(--line);
  color: var(--text);
  font-size: 15px;
  padding: 10px 2px;
  font-family: var(--sans);
  transition: border-color 0.3s ease;
}

.field input::placeholder {
  color: #555;
}

.field input:focus {
  outline: none;
  border-bottom-color: var(--gold);
}

.field.has-error input {
  border-bottom-color: #d98c8c;
}

.field .error {
  display: block;
  margin-top: 7px;
  font-size: 11.5px;
  letter-spacing: 1px;
  color: #d98c8c;
}

.btn {
  width: 100%;
  margin-top: 6px;
  padding: 14px;
  background: linear-gradient(180deg, var(--gold-soft), var(--gold));
  color: #14110b;
  border: none;
  border-radius: 2px;
  font-size: 14px;
  letter-spacing: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: filter 0.25s ease, transform 0.1s ease;
}

.btn:hover:not(:disabled) {
  filter: brightness(1.08);
}

.btn:active:not(:disabled) {
  transform: translateY(1px);
}

.btn:disabled {
  cursor: not-allowed;
  opacity: 0.65;
}

.msg {
  margin-top: 16px;
  text-align: center;
  font-size: 12.5px;
  letter-spacing: 1px;
}

.msg.success {
  color: var(--gold-soft);
}

.msg.error {
  color: #d98c8c;
}

.tip {
  margin-top: 28px;
  padding: 12px 16px;
  border: 1px dashed var(--line);
  border-radius: 3px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  text-align: center;
}

.tip-title {
  font-size: 11px;
  letter-spacing: 3px;
  color: var(--gold-soft);
}

.tip-body {
  font-size: 11.5px;
  line-height: 1.8;
  letter-spacing: 0.5px;
  color: var(--text-dim);
}

.foot {
  margin-top: 22px;
  text-align: center;
  font-size: 12px;
  letter-spacing: 1px;
  color: var(--text-dim);
}

.foot a {
  color: var(--text-dim);
  text-decoration: none;
  transition: color 0.25s ease;
}

.foot a:hover {
  color: var(--gold-soft);
}
</style>
