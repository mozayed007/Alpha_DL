@echo off
REM Disable all beeping and console sounds
for /f %%a in ('echo prompt $H ^| cmd') do set "BS=%%a"
set "BELL="
set "ConsolePid="
for /f "tokens=2 delims=;" %%a in ('tasklist /fi "imagename eq cmd.exe" /v /fo csv /nh ^| findstr /i /c:"Advanced YouTube Downloader"') do set "ConsolePid=%%~a"
if defined ConsolePid (
    nircmd.exe win settopmost title "Advanced YouTube Downloader" 0 >nul 2>&1
    nircmd.exe win setsize title "Advanced YouTube Downloader" 100 100 800 600 >nul 2>&1
)

REM Check dependencies
set "MISSING_DEPS="
echo Checking yt-dlp...
where yt-dlp >nul 2>&1 || (
    set "MISSING_DEPS=!MISSING_DEPS! yt-dlp"
    echo [X] yt-dlp not found
) && echo [√] yt-dlp found

echo Checking ffmpeg...
where ffmpeg >nul 2>&1 || (
    set "MISSING_DEPS=!MISSING_DEPS! ffmpeg"
    echo [X] ffmpeg not found
) && echo [√] ffmpeg found

echo Checking aria2c...
where aria2c >nul 2>&1 || (
    set "MISSING_DEPS=!MISSING_DEPS! aria2c"
    echo [X] aria2c not found
) && echo [√] aria2c found

echo Checking ytarchive...
where ytarchive >nul 2>&1 || (
    set "MISSING_DEPS=!MISSING_DEPS! ytarchive"
    echo [X] ytarchive not found
) && echo [√] ytarchive found

if not "!MISSING_DEPS!"=="" (
    echo.
    echo Error: Missing required components:!MISSING_DEPS!
    echo Please ensure these components are installed and in your PATH
    echo Download links:
    echo - yt-dlp: https://github.com/yt-dlp/yt-dlp/releases
    echo - ffmpeg: https://github.com/BtbN/FFmpeg-Builds/releases
    echo - aria2c: https://github.com/aria2/aria2/releases
    echo - ytarchive: https://github.com/Kethsar/ytarchive/releases
    pause
    exit /b 1
)

REM Hardware acceleration detection
set "hw_accel_available=false"
set "hw_accel="
set "hw_accel_device="

ffmpeg -hide_banner -hwaccels > "%instance_temp%\hwaccels.txt"
findstr /I "cuda" "%instance_temp%\hwaccels.txt" >nul && (
    set "hw_accel_available=true"
    set "hw_accel=cuda"
    set "hw_accel_device=0"
    echo [√] NVIDIA GPU acceleration available
    goto hw_accel_done
)

findstr /I "qsv" "%instance_temp%\hwaccels.txt" >nul && (
    set "hw_accel_available=true"
    set "hw_accel=qsv"
    echo [√] Intel Quick Sync acceleration available
    goto hw_accel_done
)

findstr /I "amf" "%instance_temp%\hwaccels.txt" >nul && (
    set "hw_accel_available=true"
    set "hw_accel=amf"
    echo [√] AMD GPU acceleration available
    goto hw_accel_done
)

echo [!] No hardware acceleration available
:hw_accel_done
del "%instance_temp%\hwaccels.txt" 2>nul

REM Set download directory based on object type and title
if defined object_type (
    if /i "%object_type%"=="playlist" (
        set "download_dir=%download_base%\playlists\%object_title%"
    ) else if /i "%object_type%"=="channel" (
        set "download_dir=%download_base%\channels\%object_title%"
    ) else (
        set "download_dir=%download_base%\others\%object_title%"
    )
) else (
    set "download_dir=%download_base%"
)
if not exist "%download_dir%" mkdir "%download_dir%"

REM Future: Initialize library components interacting with modules.

exit /b 0
