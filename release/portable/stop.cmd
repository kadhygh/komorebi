@echo off
setlocal

set "ROOT=%~dp0"
set "BIN_DIR=%ROOT%bin"

if not exist "%BIN_DIR%\komorebic.exe" (
  echo [error] Missing "%BIN_DIR%\komorebic.exe"
  echo [hint] Run release\build-portable.ps1 first, or copy the release binaries into bin\.
  exit /b 1
)

call "%BIN_DIR%\komorebic.exe" stop

if errorlevel 1 (
  exit /b %errorlevel%
)

echo komorebi stopped.
