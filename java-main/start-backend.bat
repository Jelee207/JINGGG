@echo off
rem ============================================================
rem 后端启动脚本（Spring Boot :8080）
rem 说明：target 目录每次开机会被删除，本脚本自动重新编译再启动
rem ============================================================
title springboot-backend
cd /d "%~dp0"

rem ---- 关键：覆盖 SERVER__PORT 环境变量，防止端口被其他程序抢占 ----
set "SERVER__PORT=8080"
set "SERVER__HOST=0.0.0.0"

rem ---- 检查 Java ----
where java >nul 2>nul
if errorlevel 1 (
    echo [错误] 找不到 java，请确认 JDK 已安装并配置 JAVA_HOME
    pause
    exit /b 1
)

rem ---- 检查 MySQL（3306）----
netstat -ano | findstr /C:":3306 " | findstr /C:"LISTENING" >nul
if errorlevel 1 (
    echo [提示] MySQL 未运行，尝试启动服务 MySQL80 ...
    net start MySQL80 >nul 2>nul
    timeout /t 3 /nobreak >nul
    netstat -ano | findstr /C:":3306 " | findstr /C:"LISTENING" >nul
    if errorlevel 1 (
        echo [警告] MySQL 仍未运行，后端连不上数据库，请手动启动 MySQL 后重试
    )
)

rem ---- 初始化数据库（幂等，可重复执行；确保库表和 admin 账号存在）----
set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist "%MYSQL_EXE%" (
    echo [初始化] 执行 springBootTest\sql\init.sql ...
    "%MYSQL_EXE%" -uroot -p123456 --default-character-set=utf8mb4 < "%~dp0springBootTest\sql\init.sql" >nul 2>nul
) else (
    echo [提示] 未找到 mysql.exe，跳过数据库初始化（若库已存在可忽略）
)

rem ---- 启动后端（首次会自动编译）----
echo [启动] Spring Boot 后端 http://localhost:8080
cd /d "%~dp0springBootTest"
call mvnw.cmd -B spring-boot:run -Dspring-boot.run.arguments=--server.port=8080
if errorlevel 1 (
    echo [备选] mvnw 启动失败，尝试本地缓存的 Maven ...
    call "%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.9-bin\4nf9hui3q3djbarqar9g711ggc\apache-maven-3.9.9\bin\mvn.cmd" -B spring-boot:run -Dspring-boot.run.arguments=--server.port=8080
)
echo.
echo [结束] 后端进程已退出
pause
