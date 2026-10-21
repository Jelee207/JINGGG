<template>
  <main class="card">
    <div class="brand">
      <div class="mark">AURELIA</div>
      <div class="sub">Members Login</div>
    </div>

    <form @submit.prevent="handleSubmit" novalidate>
      <div class="field" :class="{ 'has-error': errors.username }">
        <label for="username">用户名</label>
        <input
          id="username"
          v-model.trim="form.username"
          type="text"
          placeholder="请输入用户名"
          autocomplete="username"
          :aria-invalid="!!errors.username"
          @input="errors.username = ''"
        />
        <span v-if="errors.username" class="error">{{ errors.username }}</span>
      </div>

      <div class="field" :class="{ 'has-error': errors.password }">
        <label for="password">密码</label>
        <input
          id="password"
          v-model="form.password"
          type="password"
          placeholder="请输入密码"
          autocomplete="current-password"
          :aria-invalid="!!errors.password"
          @input="errors.password = ''"
        />
        <span v-if="errors.password" class="error">{{ errors.password }}</span>
      </div>

      <div class="row">
        <a class="forgot" href="#" @click.prevent="onForgot">忘记密码？</a>
      </div>

      <CaptchaField
        ref="captchaRef"
        v-model="form.captcha"
        :error="errors.captcha"
        @update:model-value="errors.captcha = ''"
      />

      <button class="btn" type="submit" :disabled="loading">
        {{ loading ? '登 录 中…' : '登 录' }}
      </button>

      <p v-if="message" class="msg" :class="message.type">{{ message.text }}</p>
    </form>

    <div class="foot">还没有账户？<a href="#" @click.prevent="onRegister">立即注册</a></div>
  </main>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { loginUser } from '../api.js'
import CaptchaField from './CaptchaField.vue'

const emit = defineEmits(['register', 'authenticated'])

const form = reactive({
  username: '',
  password: '',
  captcha: ''
})

const errors = reactive({
  username: '',
  password: '',
  captcha: ''
})

const captchaRef = ref(null)
const loading = ref(false)
const message = ref(null) // { type: 'success' | 'error', text: string }

function validate() {
  errors.username = form.username ? '' : '请输入用户名'
  errors.password = !form.password
    ? '请输入密码'
    : form.password.length < 6
      ? '密码至少 6 位'
      : ''
  errors.captcha = form.captcha ? '' : '请输入验证码'
  return !errors.username && !errors.password && !errors.captcha
}

async function handleSubmit() {
  message.value = null
  if (!validate()) return

  loading.value = true
  try {
    // 接入真实登录接口，见 src/api.js -> loginUser；成功后交由 App 进入已登录视图
    await loginUser({
      username: form.username,
      password: form.password,
      captcha: form.captcha,
      captchaToken: captchaRef.value ? captchaRef.value.getToken() : ''
    })

    emit('authenticated')
  } catch (e) {
    message.value = { type: 'error', text: e.message || '登录失败，请重试' }
  } finally {
    // 无论成功失败都刷新验证码，防止重复使用
    if (captchaRef.value) captchaRef.value.refresh()
    loading.value = false
  }
}

function onForgot() {
  // TODO: 跳转忘记密码流程
  console.log('跳转：忘记密码')
}

function onRegister() {
  emit('register')
}
</script>

<style scoped>
.card {
  width: 100%;
  max-width: 400px;
  background: linear-gradient(160deg, var(--bg-1), var(--bg-2));
  border: 1px solid var(--line);
  border-radius: 4px;
  padding: 56px 44px 40px;
  position: relative;
  box-shadow:
    0 1px 0 rgba(255, 255, 255, 0.04) inset,
    0 40px 80px -40px rgba(0, 0, 0, 0.9);
}

/* 顶部细金线 */
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
  margin-bottom: 40px;
}

.brand .mark {
  font-family: var(--serif);
  font-size: 30px;
  letter-spacing: 6px;
  color: var(--gold-soft);
  font-weight: 500;
}

.brand .sub {
  margin-top: 10px;
  font-size: 12px;
  letter-spacing: 4px;
  text-transform: uppercase;
  color: var(--text-dim);
}

.field {
  margin-bottom: 22px;
}

.field label {
  display: block;
  font-size: 12px;
  letter-spacing: 2px;
  color: var(--text-dim);
  margin-bottom: 9px;
  text-transform: uppercase;
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

.row {
  display: flex;
  justify-content: flex-end;
  margin: -6px 0 28px;
}

.forgot {
  font-size: 12.5px;
  letter-spacing: 1px;
  color: var(--text-dim);
  text-decoration: none;
  transition: color 0.25s ease;
}
.forgot:hover {
  color: var(--gold-soft);
}

.btn {
  width: 100%;
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

.btn.ghost {
  margin-top: 14px;
  background: transparent;
  border: 1px solid var(--gold);
  color: var(--gold-soft);
}
.btn.ghost:hover:not(:disabled) {
  background: rgba(201, 169, 106, 0.08);
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

.foot {
  margin-top: 26px;
  text-align: center;
  font-size: 12px;
  color: var(--text-dim);
  letter-spacing: 1px;
}
.foot a {
  color: var(--gold-soft);
  text-decoration: none;
}
.foot a:hover {
  text-decoration: underline;
}
</style>
