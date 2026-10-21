@echo off
rem ============================================================
rem 前端启动脚本（Vite :5173）
rem 注意：真实项目在 vue-login\vue-login（双层嵌套目录）
rem 说明：node_modules 每次开机会被删除，本脚本会自动重装依赖
rem ============================================================
title vue-frontend
cd /d "%~dp0vue-login\vue-login"

where npm >nul 2>nul
if errorlevel 1 (
    echo [错误] 找不到 npm，请确认 Node.js 已安装
    pause
    exit /b 1
)

if not exist node_modules (
    echo [安装] node_modules 不存在，执行 npm install ...
    call npm install
    if errorlevel 1 (
        echo [错误] 依赖安装失败，请检查网络
        pause
        exit /b 1
    )
)

echo [启动] 前端开发服务器 http://localhost:5173
echo        /api 请求会自动代理到后端 http://localhost:8080
call npm run dev
pause
