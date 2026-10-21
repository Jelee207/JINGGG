// ============================================================================
// 后端接口层（预留后端端口）
// ----------------------------------------------------------------------------
// 开发环境：Vite 已配置 /api 代理转发到后端，见 vite.config.js 的 server.proxy
//   前端请求 /api/*  ->  Vite 转发  ->  http://localhost:8080/*
// 后端默认端口：8080（Spring Boot 默认端口，可改 vite.config.js 的 target）
// 生产环境：将 API_BASE 改为后端真实域名，例如 https://api.example.com
// ============================================================================

const API_BASE = '/api'

// 登录令牌本地存储（localStorage）
const TOKEN_KEY = 'aurelia_token'

export function getToken() {
  return localStorage.getItem(TOKEN_KEY) || ''
}

export function setToken(token) {
  if (token) localStorage.setItem(TOKEN_KEY, token)
  else localStorage.removeItem(TOKEN_KEY)
}

/**
 * 登录（预留后端端口）
 * 后端约定：POST /api/login
 *   body: { username: string, password: string, captcha: string, captchaToken?: string }
 */
export async function loginUser(payload) {
  let res
  try {
    res = await fetch(`${API_BASE}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    })
  } catch {
    throw new Error('无法连接后端，请确认服务已启动（默认 http://localhost:8080）')
  }
  if (!res.ok) {
    const data = await res.json().catch(() => ({}))
    throw new Error(data.message || '登录失败，请检查用户名或密码')
  }
  const json = await res.json()
  if (json && json.data && json.data.token) setToken(json.data.token)
  return json
}

/**
 * 提交注册（预留后端端口）
 * 后端约定：POST /api/auth/register
 *   body: { username: string, password: string, captcha: string, captchaToken?: string }
 * 图形验证码由后端生成并校验：CaptchaField 组件加载时调用 GET /api/captcha
 * 展示图片（{ token, image(base64) }），提交时随表单携带 token 与用户输入。
 */
export async function registerUser(payload) {
  let res
  try {
    res = await fetch(`${API_BASE}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    })
  } catch {
    throw new Error('无法连接后端，请确认服务已启动（默认 http://localhost:8080）')
  }
  if (!res.ok) {
    const data = await res.json().catch(() => ({}))
    throw new Error(data.message || '注册失败，请重试')
  }
  return res.json()
}

/**
 * 获取图形验证码（预留后端端口）
 * 后端生成验证码图片，前端拿到 image(base64) 显示、token 随登录/注册提交。
 * CaptchaField 组件已在挂载与刷新时调用本接口。
 * 后端约定：GET /api/captcha -> { token: string, image: string }
 */
export async function getCaptcha() {
  let res
  try {
    res = await fetch(`${API_BASE}/captcha`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    })
  } catch {
    throw new Error('获取验证码失败')
  }
  if (!res.ok) throw new Error('获取验证码失败')
  return res.json()
}

/**
 * 获取当前登录用户信息（需携带 JWT）
 * 后端约定：GET /api/user/me，请求头 Authorization: Bearer <token>
 * 返回 Result<String>（用户名）；令牌失效时清空本地存储。
 */
export async function getProfile() {
  const token = getToken()
  const res = await fetch(`${API_BASE}/user/me`, {
    method: 'GET',
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  })
  if (!res.ok) {
    setToken('')
    const data = await res.json().catch(() => ({}))
    throw new Error(data.message || '获取用户信息失败')
  }
  return res.json()
}

/**
 * 首页内容流（预留后端端口）
 * 后端约定：GET /api/home/feed，请求头 Authorization: Bearer <token>
 * 返回 Result<{ categories: Category[], posts: Post[] }>
 * 后端未就绪时返回 null，前端自动回退到本地演示数据。
 */
export async function getHomeFeed() {
  try {
    const token = getToken()
    const res = await fetch(`${API_BASE}/home/feed`, {
      method: 'GET',
      headers: token ? { Authorization: `Bearer ${token}` } : {}
    })
    if (!res.ok) return null
    const json = await res.json()
    return json && json.code === 0 && json.data ? json.data : null
  } catch {
    return null // 后端未启动时静默降级，由页面使用本地演示数据
  }
}

/**
 * 站内搜索（预留后端端口）
 * 后端约定：GET /api/search?keyword=xxx&page=1&size=20
 * 返回 Result<Post[]>；后端未就绪时返回 null，前端回退到本地过滤。
 */
export async function searchAll(keyword) {
  try {
    const token = getToken()
    const res = await fetch(
      `${API_BASE}/search?keyword=${encodeURIComponent(keyword)}&page=1&size=20`,
      {
        method: 'GET',
        headers: token ? { Authorization: `Bearer ${token}` } : {}
      }
    )
    if (!res.ok) return null
    const json = await res.json()
    return json && json.code === 0 && Array.isArray(json.data) ? json.data : null
  } catch {
    return null // 后端未启动时静默降级，由页面本地过滤演示数据
  }
}

/**
 * 注销：POST /api/logout（携带当前 JWT），成功后清空本地令牌。
 */
export async function logoutUser() {
  const token = getToken()
  try {
    await fetch(`${API_BASE}/logout`, {
      method: 'POST',
      headers: token ? { Authorization: `Bearer ${token}` } : {}
    })
  } catch {
    // 忽略网络错误，仍以本地退出为准
  } finally {
    setToken('')
  }
}
