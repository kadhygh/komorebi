@echo off
setlocal

set "ROOT=%~dp0"
set "BIN_DIR=%ROOT%bin"
set "CONFIG_DIR=%ROOT%config"

if not exist "%BIN_DIR%\komorebi.exe" (
  echo [error] Missing "%BIN_DIR%\komorebi.exe"
  echo [hint] Run release\build-portable.ps1 first, or copy the release binaries into bin\.
  exit /b 1
)

if not exist "%CONFIG_DIR%\komorebi.json" (
  echo [error] Missing "%CONFIG_DIR%\komorebi.json"
  exit /b 1
)

if not exist "%CONFIG_DIR%\applications.json" (
  echo [error] Missing "%CONFIG_DIR%\applications.json"
  echo [hint] Run release\build-portable.ps1 first to stage the portable package.
  exit /b 1
)

set "KOMOREBI_CONFIG_HOME=%CONFIG_DIR%"
set "WHKD_CONFIG_HOME=%CONFIG_DIR%"

start "" "%BIN_DIR%\komorebi.exe"

if errorlevel 1 (
  exit /b %errorlevel%
)

echo komorebi started.
echo Config home: "%KOMOREBI_CONFIG_HOME%"
echo If you want hotkeys, run "shortcuts\komorebi.ahk" with AutoHotkey v2.
echo If you want whkd integration, use "start-whkd.cmd" instead.
