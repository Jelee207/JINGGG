@echo off
rem ============================================================
rem 一键启动：后端(8080) + 前端(5173)，各自独立窗口运行
rem ============================================================
start "springboot-backend" cmd /c "%~dp0start-backend.bat"
start "vue-frontend" cmd /c "%~dp0start-frontend.bat"
echo [完成] 两个窗口已启动，稍等编译安装完成。
echo        浏览器访问 http://localhost:5173（演示账号 admin / admin123）
pause
