@echo off
setlocal EnableDelayedExpansion EnableExtensions
chcp 65001 >nul 2>&1
title Advanced YouTube Downloader (Alpha Utility)
color 0b 2>nul

REM Set script directory as base path for all includes
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Load core components
call "%SCRIPT_DIR%config\settings.bat"
call "%SCRIPT_DIR%config\paths.bat"
call "%SCRIPT_DIR%lib\init.bat"

if errorlevel 1 (
    echo Error initializing system
    pause
    exit /b 1
)

REM Initialize error handling
set "previous_operation="
set "error_code="
set "error_msg="

REM Configure ffmpeg for hardware acceleration
set "ffmpeg_args="
if "%hw_accel_available%"=="true" (
    set "ffmpeg_args=--postprocessor-args ffmpeg:-hwaccel !hw_accel! -hwaccel_device !hw_accel_device! -threads auto"
)

:main_loop
call "%SCRIPT_DIR%utils\menu.bat"
if errorlevel 1 goto :cleanup

goto :main_loop

:cleanup
call "%SCRIPT_DIR%utils\cleanup.bat"
exit /b 0
