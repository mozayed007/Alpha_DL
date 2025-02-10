@echo off
REM Version info
set "VERSION=1.0.1"
set "LAST_UPDATED=2025-01"

REM Default settings
set "use_sponsorblock=false"
set "use_aria2c=true"
set "embed_subs=true"
set "auto_subs=true"
set "embed_thumb=true"
set "embed_meta=true"
set "format_selection=bestvideo*+bestaudio/best"
set "quality_str=Best Quality"

REM Set up directory structure with short paths
pushd "%~dp0.."
set "BASE_DIR=%CD%"
popd
set "DOWNLOAD_DIR=%BASE_DIR%\downloads"
set "TEMP_DIR=%DOWNLOAD_DIR%\.temp"
set "CACHE_DIR=%DOWNLOAD_DIR%\.cache"
set "LOG_DIR=%DOWNLOAD_DIR%\.logs"

REM Create directory structure silently
md "%DOWNLOAD_DIR%" 2>nul
md "%DOWNLOAD_DIR%\videos" 2>nul
md "%DOWNLOAD_DIR%\playlists" 2>nul
md "%DOWNLOAD_DIR%\channels" 2>nul
md "%DOWNLOAD_DIR%\audio" 2>nul
md "%DOWNLOAD_DIR%\live" 2>nul
md "%TEMP_DIR%" 2>nul
md "%CACHE_DIR%" 2>nul
md "%LOG_DIR%" 2>nul

REM Configure base arguments for yt-dlp
set "ytdlp_base_args=--no-mtime --no-call-home --no-check-certificate --progress"

REM Configure aria2c profiles for different file sizes
set "aria2c_small=aria2c:-x4 -s4 -j2 -k1M --optimize-concurrent-downloads=true --max-overall-download-limit=5M --min-split-size=5M"
set "aria2c_medium=aria2c:-x8 -s8 -j4 -k1M --optimize-concurrent-downloads=true --max-overall-download-limit=10M --min-split-size=5M"
set "aria2c_large=aria2c:-x16 -s16 -j8 -k1M --optimize-concurrent-downloads=true --max-overall-download-limit=0 --min-split-size=5M"

REM Default to medium profile with common options
set "aria2c_common=--console-log-level=notice --summary-interval=1 --file-allocation=none --show-console-readout=true --download-result=full --auto-file-renaming=false --human-readable=true"
set "aria2c_profile=medium"

REM Function to set aria2c profile based on file size (called by download modules)
:set_aria2c_profile
if "%~1"=="" goto :eof
set "filesize=%~1"
if %filesize% LEQ 104857600 (
    REM Less than 100MB
    set "aria2c_profile=small"
) else if %filesize% LEQ 524288000 (
    REM Less than 500MB
    set "aria2c_profile=medium"
) else (
    REM Larger than 500MB
    set "aria2c_profile=large"
)
if "%aria2c_profile%"=="small" set "aria2c_args=--downloader aria2c --downloader-args "%aria2c_small% %aria2c_common%""
if "%aria2c_profile%"=="medium" set "aria2c_args=--downloader aria2c --downloader-args "%aria2c_medium% %aria2c_common%""
if "%aria2c_profile%"=="large" set "aria2c_args=--downloader aria2c --downloader-args "%aria2c_large% %aria2c_common%""
goto :eof

REM Configure aria2c with default medium profile
set "use_aria2c=true"
set "aria2c_args=--downloader aria2c --downloader-args "%aria2c_medium% %aria2c_common%"""

REM Error codes
set "ERROR_NETWORK=1"
set "ERROR_UNAVAILABLE=2"
set "ERROR_PERMISSION=3"
set "ERROR_HW_ACCEL=4"
set "ERROR_ARIA2C=5"
set "ERROR_INIT=6"
set "ERROR_UNKNOWN=9"

REM Error messages
set "ERROR_MSG_NETWORK=Network connectivity problem"
set "ERROR_MSG_UNAVAILABLE=Video unavailable or private"
set "ERROR_MSG_PERMISSION=Insufficient permissions"
set "ERROR_MSG_HW_ACCEL=Hardware acceleration error"
set "ERROR_MSG_ARIA2C=aria2c download error"
set "ERROR_MSG_INIT=Initialization error"
set "ERROR_MSG_UNKNOWN=Unknown error occurred"

REM Network settings
set "proxy_args="
set "retry_args=--retries 10 --fragment-retries 10 --retry-sleep 5"

REM Hardware acceleration
set "hw_accel_available=false"
set "hw_accel="
set "hw_accel_device="
set "ffmpeg_args="

exit /b 0
