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

if not exist "%CONFIG_DIR%\whkdrc" (
  echo [error] Missing "%CONFIG_DIR%\whkdrc"
  echo [hint] This script is for users who want to start komorebi with whkd.
  exit /b 1
)

set "KOMOREBI_CONFIG_HOME=%CONFIG_DIR%"
set "WHKD_CONFIG_HOME=%CONFIG_DIR%"
set "PATH=%BIN_DIR%;%PATH%"

where whkd.exe >nul 2>nul
if errorlevel 1 (
  echo [error] Could not find whkd.exe in PATH
  echo [hint] Install whkd first, or use start.cmd with the AHK example instead.
  exit /b 1
)

set "START_ARGS=start --whkd"
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

echo komorebi started with whkd.
echo Config home: "%KOMOREBI_CONFIG_HOME%"
echo Bar: %BAR_STATUS%
if "%BAR_STATUS%"=="disabled" echo [hint] No komorebi-bar.exe was found in bin\ or PATH, so this start skipped --bar.
echo To stop whkd-mode startup, run: "%BIN_DIR%\komorebic.exe" stop --whkd --bar
