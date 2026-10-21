# AGENT-README —— 给 AI 助手的快速上手说明（读完再动手，能省一半时间）

> 这个文件是写给 AI 助手（WorkBuddy / Claude 等）的项目环境备忘。
> 本机每次开机可能重置（node_modules、target 会被删除），服务需要重新拉起。
> 下次接手任何"启动 / 联调 / 改造"任务前，**先读完本文件**，不要重新探索环境。

## 一、项目结构（注意嵌套）

```
java-main\java-main\
├── springBootTest\          ← Spring Boot 3.4.5 后端（端口 8080）
│   ├── mvnw.cmd             ← Maven wrapper，直接用它，机器无全局 mvn
│   └── sql\init.sql         ← 建库建表 + admin 演示账号，幂等可重复执行
├── vue-login\vue-login\     ← Vue3 + Vite 前端（端口 5173）⚠️ 双层嵌套目录！
│   └── vite.config.js       ← /api 代理到 http://localhost:8080
├── start-backend.bat / stop-backend.bat      ← 已写好的启停脚本（GBK）
├── start-frontend.bat / stop-frontend.bat   ← 同上
├── start-all.bat / stop-all.bat              ← 一键启动/停止
└── AGENT-README.md          ← 本文件
```

## 二、环境事实（已验证，直接用，别再排查）

| 项 | 值 |
|---|---|
| JDK | Zulu 21（`JAVA_HOME=C:\Program Files\Zulu\zulu-21\`，系统变量已配好） |
| Maven | 无全局安装；用项目 `mvnw.cmd`（缓存于 `~/.m2/wrapper/dists`，3.9.9/3.9.16 都有） |
| MySQL | 8.0，`C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`，root/123456，端口 3306 |
| 数据库 | `springboot_test`，表 `sys_user`；演示账号 **admin / admin123** |
| 密码算法 | `SHA-256(salt + 明文)`，小写 hex，salt 32 位 hex（见 PasswordUtil） |

## 三、⚠️ 最大的坑：SERVER__PORT 环境变量

从 WorkBuddy 里启动 Spring Boot 时，进程环境自带 `SERVER__PORT=<随机端口>` 和
`SERVER__HOST=127.0.0.1`。Spring Boot 宽松绑定把它当 `server.port`，且 **OS 环境变量
优先级高于 application-*.properties**，导致启动报 `Port xxx already in use`。

**解决办法（任选其一）：**
1. 启动命令带 `-Dspring-boot.run.arguments=--server.port=8080`（推荐）
2. 启动前 `SERVER__PORT=8080 SERVER__HOST=0.0.0.0`（bat 脚本里已经这么干了）

## 四、快速启动（用户日常就用脚本）

- 用户自己：双击 `start-all.bat`（后端+前端各开一个窗口）
- AI 启动后端：
  ```bash
  cd C:/Users/Administrator/Desktop/java-main/java-main/springBootTest
  ./mvnw.cmd -B spring-boot:run -Dspring-boot.run.arguments=--server.port=8080
  ```
- AI 启动前端（node_modules 被删时先 `npm install`）：
  ```bash
  cd C:/Users/Administrator/Desktop/java-main/java-main/vue-login/vue-login
  npm install && npm run dev
  ```
- 初始化/修复数据库：
  ```bash
  "/c/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe" -uroot -p123456 --default-character-set=utf8mb4 < sql/init.sql
  ```
- 停止服务：找到监听端口的 PID（`netstat -ano | findstr :8080`）→ taskkill /F /PID

## 五、接口契约（前后端已对齐，2026-10-10 全链路实测通过）

| 接口 | 说明 |
|---|---|
| `GET /api/captcha` | 返回 `{token, image(base64 png)}`，白名单免登录 |
| `POST /api/login` | `{username, password, captcha, captchaToken}` → `{data:{token}}` JWT |
| `POST /api/auth/register` | 同上结构，密码≥6位 |
| `GET /api/user/me` | 需 `Authorization: Bearer <token>` → `{data:"用户名"}` |
| `POST /api/logout` | 需 Bearer，token 进黑名单，之后 401 |

**自动化测试技巧**：验证码图片可以 base64 解码存成 PNG，用能读图的工具直接看图识别
文字（实测可行），即可脚本化跑通"注册→登录→me→注销"全链路。

## 六、已知小问题（修过/可留意）

- `application.properties` 原第 11 行 `logging.pattern.file` 的值里误写了
  `logging.pattern.console=` 前缀（已修复）；中文注释乱码（已修复）。
- `mybatis-plus.mapper-locations` 指向不存在的 `mapper/*.xml`，无实际影响（纯注解开发）。
- 前端 `api.js` 的注释曾与实际实现不符，已修正。

## 七、其他备忘

- WorkBuddy 沙箱会拦截 `sc.exe`、`wmic.exe`；查服务/进程用 PowerShell 工具。
- Git Bash 里 `taskkill //F //PID` 不行，要么用 PowerShell，要么 `cmd //c "taskkill /F /PID xxx"`。
- MySQL 服务名大概率是 `MySQL80`（脚本里 net start 兜底）。
