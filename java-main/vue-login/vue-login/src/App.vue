<template>
  <!-- ================= 后台管理系统 ================= -->
  <template v-if="route === '/admin'">
    <AdminView
      v-if="adminReady"
      :username="adminUser"
      @logout="onAdminLogout"
      @back="goFront"
    />
    <div v-else class="adm-empty">正在校验后台登录状态…</div>
  </template>

  <template v-else-if="route === '/admin/login'">
    <AdminLoginView
      v-if="!adminReady"
      @authenticated="onAdminLogin"
      @back="goFront"
    />
    <div v-else class="adm-empty">正在进入后台管理系统…</div>
  </template>

  <!-- ================= 前台站点 ================= -->
  <LoginView
    v-else-if="view === 'login'"
    @register="view = 'register'"
    @authenticated="onAuthenticated"
  />
  <RegisterView v-else-if="view === 'register'" @login="view = 'login'" />
  <HomeView
    v-else-if="view === 'home'"
    :username="username"
    :permission="permission"
    @nav="onFrontNav"
    @logout="onLogout"
    @admin="goAdminLogin"
  />
  <AuctionView
    v-else-if="view === 'auction'"
    :username="username"
    :permission="permission"
    @nav="onFrontNav"
    @logout="onLogout"
    @admin="goAdminLogin"
  />
  <HomeView v-else :username="username" :permission="permission" @logout="onLogout" @admin="goAdminLogin" />
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import LoginView from './components/LoginView.vue'
import RegisterView from './components/RegisterView.vue'
import HomeView from './components/HomeView.vue'
import AuctionView from './components/AuctionView.vue'
import AdminLoginView from './components/AdminLoginView.vue'
import AdminView from './components/AdminView.vue'
import { getToken, getProfile, logoutUser, getAdminToken, setAdminToken, adminMe } from './api.js'

const view = ref('login')      // login | register | home（前台）
const username = ref('')
const permission = ref(1)       // 0 管理员，1 默认会员；控制首页「后台管理系统」入口
const adminUser = ref('')      // 后台登录管理员昵称
const adminReady = ref(false)  // 后台令牌是否已校验通过
const route = ref('/')

/* ---------------- 简易 hash 路由 ---------------- */
function normalize(hash) {
  const h = String(hash || '').replace(/^#/, '').replace(/\/+$/, '') || '/'
  return h === '/admin' || h === '/admin/login' || h === '/register' ? h : '/'
}

function goAdminLogin() {
  location.hash = '#/admin/login'
}

function goFront() {
  location.hash = '#/'
}

function applyRoute() {
  const r = normalize(location.hash)
  route.value = r
  document.body.classList.toggle('admin-mode', r === '/admin')
  if (r === '/admin/login' && adminReady.value) {
    location.hash = '#/admin'
  } else if (r === '/admin' && !adminReady.value) {
    location.hash = '#/admin/login'
  }
}

/* ---------------- 初始化 ---------------- */
onMounted(async () => {
  // 1) 前台会话：本地有会员令牌则向后端校验，有效直接进入首页
  if (getToken()) {
    try {
      const res = await getProfile()
      if (res && res.code === 0 && res.data) {
        applyProfile(res)
        view.value = 'home'
      } else {
        await logoutUser()
      }
    } catch {
      await logoutUser()
    }
  }

  // 2) 后台会话：本地有管理员令牌则校验，有效则直接进入后台
  await checkAdmin()

  // 3) 路由：支持直接访问 #/admin、#/admin/login 等地址
  applyRoute()
  window.addEventListener('hashchange', applyRoute)
})

watch(() => route.value, (r) => {
  document.body.classList.toggle('admin-mode', r === '/admin')
})

async function checkAdmin() {
  if (!getAdminToken()) {
    adminReady.value = false
    return
  }
  try {
    const data = await adminMe()
    adminUser.value = (data && (data.nickname || data.username)) || ''
    adminReady.value = true
  } catch {
    setAdminToken('')
    adminReady.value = false
  }
}

/* ---------------- 前台事件 ---------------- */
async function onAuthenticated() {
  try {
    const res = await getProfile()
    applyProfile(res)
  } catch {
    username.value = ''
    permission.value = 1
  }
  view.value = 'home'
}

/** 解析 /user/me 返回的用户信息（兼容旧的字符串返回值） */
function applyProfile(res) {
  const info = res && res.data
  if (!info) return
  if (typeof info === 'string') {
    username.value = info
    permission.value = 1
  } else {
    username.value = info.username || ''
    permission.value = info.permission ?? 1
  }
}

async function onLogout() {
  await logoutUser()
  username.value = ''
  view.value = 'login'
}

/* 前台导航：首页 / 竞拍 切换（由 TopNav 的 @nav 触发） */
function onFrontNav(key) {
  if (key === 'home') view.value = 'home'
  else if (key === 'auction') view.value = 'auction'
}

/* ---------------- 后台事件 ---------------- */
async function onAdminLogin() {
  await checkAdmin()
  if (adminReady.value) location.hash = '#/admin'
}

function onAdminLogout() {
  setAdminToken('')
  adminUser.value = ''
  adminReady.value = false
  location.hash = '#/admin/login'
}
</script>
