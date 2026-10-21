@echo off
rem 停止前端（释放 5173 端口）
title stop-frontend
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /C:":5173 " ^| findstr /C:"LISTENING"') do (
    echo [停止] 结束前端进程 PID=%%p
    taskkill /F /PID %%p >nul 2>nul
)
echo [完成] 前端已停止
pause
