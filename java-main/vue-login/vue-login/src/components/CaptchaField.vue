<template>
  <div class="field" :class="{ 'has-error': error }">
    <label for="captcha">图形验证码</label>
    <div class="captcha-row">
      <input
        id="captcha"
        :value="modelValue"
        class="captcha-input"
        type="text"
        placeholder="请输入右侧字符"
        autocomplete="off"
        maxlength="4"
        :aria-invalid="!!error"
        @input="$emit('update:modelValue', $event.target.value)"
      />
      <img
        v-if="image"
        :src="image"
        class="captcha-img"
        title="点击刷新验证码"
        alt="验证码"
        @click="refresh"
      />
      <span v-else class="captcha-loading" @click="refresh">加载中…</span>
    </div>
    <span v-if="error" class="error">{{ error }}</span>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  error: { type: String, default: '' }
})
const emit = defineEmits(['update:modelValue'])

const image = ref('')
const token = ref('')

// 校验已移至后端（CaptchaService），前端仅做非空校验，提交时携带 token
async function load() {
  try {
    const res = await fetch('/api/captcha')
    const json = await res.json()
    if (json && json.code === 0 && json.data) {
      token.value = json.data.token
      image.value = json.data.image
    }
  } catch (e) {
    // 后端不可用时静默失败，避免阻塞页面（提交时后端会返回验证码失效）
  }
}

function refresh() {
  emit('update:modelValue', '')
  load()
}

// 供父组件提交时获取当前 token
function getToken() {
  return token.value
}

onMounted(load)
defineExpose({ getToken, refresh })
</script>

<style scoped>
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

.captcha-row {
  display: flex;
  align-items: flex-end;
  gap: 12px;
}

.captcha-input {
  flex: 1;
  min-width: 0;
}

.captcha-img {
  flex-shrink: 0;
  width: 112px;
  height: 42px;
  border: 1px solid var(--line);
  border-radius: 2px;
  cursor: pointer;
  display: block;
}

.captcha-img:hover {
  border-color: var(--gold);
}

.captcha-loading {
  flex-shrink: 0;
  width: 112px;
  height: 42px;
  border: 1px dashed var(--line);
  border-radius: 2px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  color: var(--text-dim);
  cursor: pointer;
}
</style>
