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
// 后台管理系统令牌：与前台会员令牌分开存放，登录后台不影响前台会话
const ADMIN_TOKEN_KEY = 'aurelia_admin_token'

/**
 * 通用请求：统一处理网络异常、HTTP 错误码与后端 Result 结构。
 * @returns {Promise<any>} 成功返回 Result.data；失败抛 Error（message 取后端提示）
 */
async function request(path, { method = 'GET', body = null, admin = false } = {}) {
  const token = admin ? localStorage.getItem(ADMIN_TOKEN_KEY) : localStorage.getItem(TOKEN_KEY)
  const headers = { 'Content-Type': 'application/json' }
  if (token) headers.Authorization = `Bearer ${token}`

  let res
  try {
    res = await fetch(`${API_BASE}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined
    })
  } catch {
    throw new Error('无法连接后端，请确认服务已启动（默认 http://localhost:8080）')
  }

  const json = await res.json().catch(() => null)
  if (!res.ok || (json && json.code !== 0)) {
    const msg = (json && json.message) || '请求失败，请重试'
    if (res.status === 401) throw Object.assign(new Error(msg), { unauthorized: true })
    throw new Error(msg)
  }
  return json ? json.data : null
}

export function getToken() {
  return localStorage.getItem(TOKEN_KEY) || ''
}

export function setToken(token) {
  if (token) localStorage.setItem(TOKEN_KEY, token)
  else localStorage.removeItem(TOKEN_KEY)
}

export function getAdminToken() {
  return localStorage.getItem(ADMIN_TOKEN_KEY) || ''
}

export function setAdminToken(token) {
  if (token) localStorage.setItem(ADMIN_TOKEN_KEY, token)
  else localStorage.removeItem(ADMIN_TOKEN_KEY)
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

/* ============================================================================
 * 首页对外接口（数据源同后台管理）
 * ==========================================================================*/

/**
 * 首页内容流（对接后端 GET /api/home/feed）
 * 返回 Result<{ categories, posts, hotKeywords }>
 * 后端未就绪（返回 null）时由页面使用本地演示数据。
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

/* ============================================================================
 * 竞拍接口（演示数据由 Spring Boot 内存提供，后端未就绪时前端回退本地 mock）
 * ==========================================================================*/

/**
 * 拍品列表：GET /api/auction/lots
 * 返回 Result<Lot[]>；后端未就绪返回 null，AuctionView 回退到本地演示数据。
 */
export async function getAuctionLots() {
  try {
    const token = getToken()
    const res = await fetch(`${API_BASE}/auction/lots`, {
      method: 'GET',
      headers: token ? { Authorization: `Bearer ${token}` } : {}
    })
    if (!res.ok) return null
    const json = await res.json()
    return json && json.code === 0 && Array.isArray(json.data) ? json.data : null
  } catch {
    return null // 后端未启动时静默降级
  }
}

/**
 * 出价：POST /api/auction/bid  body { lotId, amount }
 * 返回 Result<Lot>（更新后的拍品）；失败抛错，由页面本地兜底。
 */
export async function placeBid(lotId, amount) {
  const token = getToken()
  const res = await fetch(`${API_BASE}/auction/bid`, {
    method: 'POST',
    headers: token
      ? { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }
      : { 'Content-Type': 'application/json' },
    body: JSON.stringify({ lotId, amount })
  })
  if (!res.ok) {
    const data = await res.json().catch(() => ({}))
    throw new Error(data.message || '出价失败')
  }
  const json = await res.json()
  if (json && json.code === 0 && json.data) return json.data
  throw new Error((json && json.message) || '出价失败')
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

/* ============================================================================
 * 后台管理系统接口（token 与前台会员相互独立）
 * ==========================================================================*/

/**
 * 后台登录：POST /api/admin/login（无验证码）
 * 成功返回 { token, username, nickname, role }，并写入本地 admin token。
 */
export async function adminLogin(username, password) {
  const data = await request('/admin/login', {
    method: 'POST',
    body: { username, password }
  })
  if (data && data.token) setAdminToken(data.token)
  return data
}

/** 当前管理员信息：GET /api/admin/me */
export function adminMe() {
  return request('/admin/me', { admin: true })
}

/** 后台退出：POST /api/admin/logout */
export async function adminLogout() {
  try {
    await request('/admin/logout', { method: 'POST', admin: true })
  } catch {
    // 忽略网络错误，仍以本地退出为准
  } finally {
    setAdminToken('')
  }
}

/** 后台概览统计：GET /api/admin/home/overview */
export function getAdminOverview() {
  return request('/admin/home/overview', { admin: true })
}

/* ---------------- 首页分类管理 ---------------- */
export function listCategories() {
  return request('/admin/home/categories', { admin: true })
}
export function createCategory(body) {
  return request('/admin/home/categories', { method: 'POST', body, admin: true })
}
export function updateCategory(id, body) {
  return request(`/admin/home/categories/${id}`, { method: 'PUT', body, admin: true })
}
export function deleteCategory(id) {
  return request(`/admin/home/categories/${id}`, { method: 'DELETE', admin: true })
}

/* ---------------- 首页精选内容管理 ---------------- */
export function listPosts(params = {}) {
  const qs = new URLSearchParams()
  if (params.keyword) qs.set('keyword', params.keyword)
  if (params.category) qs.set('category', params.category)
  const query = qs.toString()
  return request(`/admin/home/posts${query ? '?' + query : ''}`, { admin: true })
}
export function createPost(body) {
  return request('/admin/home/posts', { method: 'POST', body, admin: true })
}
export function updatePost(id, body) {
  return request(`/admin/home/posts/${id}`, { method: 'PUT', body, admin: true })
}
export function deletePost(id) {
  return request(`/admin/home/posts/${id}`, { method: 'DELETE', admin: true })
}

/* ---------------- 热门搜索词管理 ---------------- */
export function listKeywords() {
  return request('/admin/home/keywords', { admin: true })
}
export function createKeyword(body) {
  return request('/admin/home/keywords', { method: 'POST', body, admin: true })
}
export function updateKeyword(id, body) {
  return request(`/admin/home/keywords/${id}`, { method: 'PUT', body, admin: true })
}
export function deleteKeyword(id) {
  return request(`/admin/home/keywords/${id}`, { method: 'DELETE', admin: true })
}
