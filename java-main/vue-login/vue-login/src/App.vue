<template>
  <LoginView
    v-if="view === 'login'"
    @register="view = 'register'"
    @authenticated="onAuthenticated"
  />
  <RegisterView v-else-if="view === 'register'" @login="view = 'login'" />
  <HomeView v-else :username="username" @logout="onLogout" />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import LoginView from './components/LoginView.vue'
import RegisterView from './components/RegisterView.vue'
import HomeView from './components/HomeView.vue'
import { getToken, getProfile, logoutUser } from './api.js'

const view = ref('login')
const username = ref('')

// 刷新页面时，若本地仍有 token，则向 /api/user/me 校验是否仍有效，有效则直接进入已登录视图
onMounted(async () => {
  if (!getToken()) return
  try {
    const res = await getProfile()
    if (res && res.code === 0 && res.data) {
      username.value = res.data
      view.value = 'home'
    } else {
      await logoutUser()
    }
  } catch {
    await logoutUser()
  }
})

async function onAuthenticated() {
  try {
    const res = await getProfile()
    username.value = (res && res.data) || ''
  } catch {
    username.value = ''
  }
  view.value = 'home'
}

async function onLogout() {
  await logoutUser()
  username.value = ''
  view.value = 'login'
}
</script>
