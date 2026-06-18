@echo off
setlocal

chcp 936

"%~dp0/../mpv.com" --config=no --register
if %errorlevel% neq 0 (
	echo ========================================
	echo 注册失败。应确保 mpv.com 与 mpv.exe 在上级目录中
	echo ========================================
	pause
	exit /b %errorlevel%
)

chcp 936

echo ========================================
echo 注册成功。
echo 请不要变更 mpv.exe 的位置。
echo 若需移动该文件，只需重新运行此文件即可重新注册。
echo ========================================

pause
endlocal
