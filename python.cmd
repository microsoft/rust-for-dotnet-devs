@echo off
setlocal
set PATH=%~dp0.python;%~dp0.python\Scripts;%PATH%
python.exe -s -E %*
