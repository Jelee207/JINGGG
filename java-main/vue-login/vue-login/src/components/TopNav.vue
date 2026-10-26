<template>
  <header class="nav">
    <div class="nav-inner">
      <a class="logo" href="#" @click.prevent="onNav('home')">
        AURELIA<span>CLUB</span>
      </a>

      <nav class="links">
        <a
          v-for="item in navItems"
          :key="item.key"
          href="#"
          :class="{ active: item.key === active }"
          @click.prevent="onNav(item.key)"
        >{{ item.label }}</a>
      </nav>

      <button v-if="permission === 0" class="admin-entry" type="button" @click="onAdmin">
        <span class="gear">◈</span>
        <span>后台管理系统</span>
      </button>

      <div class="user" @mouseleave="menuOpen = false">
        <button class="user-btn" type="button" @click="menuOpen = !menuOpen">
          <span class="avatar">{{ initial }}</span>
          <span class="name">{{ username || '尊贵会员' }}</span>
          <span class="caret">▾</span>
        </button>
        <transition name="fade">
          <div v-if="menuOpen" class="menu">
            <a href="#" @click.prevent="onNav('profile')">个人资料</a>
            <a href="#" @click.prevent="onNav('settings')">账户设置</a>
            <a class="danger" href="#" @click.prevent="onLogout">退出登录</a>
          </div>
        </transition>
      </div>
    </div>
    <!-- 导航底部细金线 -->
    <div class="nav-line"></div>
  </header>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  username: { type: String, default: '' },
  // 权限：0 管理员，1 默认会员；仅管理员（0）可见后台管理系统入口
  permission: { type: Number, default: 1 },
  // 当前高亮项：home | auction
  active: { type: String, default: 'home' }
})
const emit = defineEmits(['nav', 'logout', 'admin'])

/* ---------------- 导航栏 ---------------- */
const menuOpen = ref(false)
const navItems = [
  { key: 'home', label: '首页' },
  { key: 'auction', label: '竞拍' }
]

const initial = computed(() => {
  const n = props.username || '会员'
  return n.charAt(0).toUpperCase()
})

function onNav(key) {
  // 占位跳转：由父级（App）决定切换到首页或竞拍
  emit('nav', key)
  menuOpen.value = false
}

/* 跳转后台管理系统 */
function onAdmin() {
  menuOpen.value = false
  emit('admin')
}

function onLogout() {
  emit('logout')
}
</script>

<style scoped lang="scss">
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

  span {
    font-size: 10px;
    letter-spacing: 3px;
    color: var(--text-dim);
    margin-left: 8px;
    vertical-align: middle;
  }
}

.links {
  display: flex;
  gap: 30px;
  flex: 1;
  justify-content: flex-start;
  flex-wrap: wrap;

  a {
    font-size: 13px;
    letter-spacing: 2px;
    color: var(--text-dim);
    text-decoration: none;
    padding-bottom: 4px;
    border-bottom: 1px solid transparent;
    transition: color 0.25s ease, border-color 0.25s ease;

    &:hover {
      color: var(--text);
    }
    &.active {
      color: var(--gold-soft);
      border-bottom-color: var(--gold);
    }
  }
}

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

  .gear {
    font-size: 11px;
    color: var(--gold);
  }
  &:hover {
    background: rgba(201, 169, 106, 0.1);
    color: var(--gold);
  }
  &:active {
    transform: translateY(1px);
  }
}

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

  &:hover {
    border-color: var(--gold);
  }
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

  a {
    display: block;
    padding: 10px 18px;
    font-size: 12.5px;
    letter-spacing: 1px;
    color: var(--text-dim);
    text-decoration: none;
    transition: color 0.2s ease, background 0.2s ease;

    &:hover {
      color: var(--gold-soft);
      background: rgba(201, 169, 106, 0.06);
    }
    &.danger:hover {
      color: #d98c8c;
    }
  }
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

@media (max-width: 640px) {
  .nav-inner {
    flex-wrap: wrap;
    gap: 16px;
  }
  .links {
    order: 3;
    width: 100%;
    justify-content: flex-start;
    gap: 18px;
  }
}
</style>
