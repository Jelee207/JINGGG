@echo off
rem 停止后端（释放 8080 端口）
title stop-backend
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /C:":8080 " ^| findstr /C:"LISTENING"') do (
    echo [停止] 结束后端进程 PID=%%p
    taskkill /F /PID %%p >nul 2>nul
)
echo [完成] 后端已停止
pause
