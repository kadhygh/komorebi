@echo off
setlocal

set "ROOT=%~dp0"
set "BIN_DIR=%ROOT%bin"
set "CONFIG_DIR=%ROOT%config"

if not exist "%BIN_DIR%\komorebic-no-console.exe" (
  echo [error] Missing "%BIN_DIR%\komorebic-no-console.exe"
  echo [hint] Run release\build-portable.ps1 first, or copy the release binaries into bin\.
  exit /b 1
)

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
set "PATH=%BIN_DIR%;%PATH%"

set "START_ARGS=start"
set "BAR_STATUS=disabled"

where komorebi-bar.exe >nul 2>nul
if not errorlevel 1 (
  set "START_ARGS=%START_ARGS% --bar"
  set "BAR_STATUS=enabled (--bar)"
)

"%BIN_DIR%\komorebic-no-console.exe" %START_ARGS%

if errorlevel 1 (
  exit /b %errorlevel%
)

echo komorebi started.
echo Config home: "%KOMOREBI_CONFIG_HOME%"
echo Bar: %BAR_STATUS%
if "%BAR_STATUS%"=="disabled" echo [hint] No komorebi-bar.exe was found in bin\ or PATH, so this start skipped --bar.
echo If you want hotkeys, run "shortcuts\komorebi.ahk" with AutoHotkey v2.
echo If you want whkd integration, use "start-whkd.cmd" instead.
