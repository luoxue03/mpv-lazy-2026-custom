@echo off
setlocal

chcp 936

"%~dp0/../mpv.com" --config=no --unregister
if %errorlevel% neq 0 (
	echo ========================================
	echo 反注册失败。应确保 mpv.com 与 mpv.exe 在上级目录中
	echo ========================================
	pause
	exit /b %errorlevel%
)

chcp 936

echo ========================================
echo 反注册成功。
echo ========================================

pause
endlocal
