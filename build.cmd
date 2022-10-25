@echo off
setlocal
pushd "%~dp0"
if not exist out mkdir out || exit /b 1
call python.cmd -m grip rust-for-dotnet-dev.md --export out\index.html
exit /b %ERRORLEVEL%
