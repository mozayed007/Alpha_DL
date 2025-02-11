@echo off
setlocal EnableDelayedExpansion

if "%~1"=="download_live" goto download_live
if "%~1"=="live_stream" goto live_stream
goto :eof

:download_live
cls
echo ===================================================
echo              Download Live Stream
echo ===================================================
echo.
echo Select Quality:
echo  1. Best Quality   (max resolution + best audio)
echo  2. 1080p         (FHD)
echo  3. 720p          (HD)
echo.
set /p "quality=Select quality (1-3): "
set /p "link=Enter live stream URL: "

REM Set format based on quality selection
if "%quality%"=="1" (
    set "format_selection=bestvideo*+bestaudio/best"
    set "quality_str=Best Quality"
)
if "%quality%"=="2" (
    set "format_selection=bestvideo[height<=1080]+bestaudio/best[height<=1080]/best"
    set "quality_str=1080p"
)
if "%quality%"=="3" (
    set "format_selection=bestvideo[height<=720]+bestaudio/best[height<=720]/best"
    set "quality_str=720p"
)

REM Set metadata embedding options
set "metadata_opts=--write-thumbnail --embed-thumbnail --write-subs --write-auto-subs --embed-subs --embed-metadata --convert-thumbnails jpg"

REM Set output template for live streams
set "output_template=%LIVE_OUT%"

REM Display download information
echo.
echo [Download Information]
echo • Content Type: live stream
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: %output_template%
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Add live-specific arguments
set "live_args=--live-from-start --wait-for-video 5-30 --retries infinite --concurrent-fragments 5"

REM Get stream info and set appropriate download profile
for /f "tokens=1" %%a in ('yt-dlp.exe --print filesize "%link%" 2^>nul') do (
    if not "%%a"=="" if not "%%a"=="NA" call "%~dp0..\config\settings.bat" :set_aria2c_profile "%%a"
)

yt-dlp.exe %ytdlp_base_args% %live_args% -f "%format_selection%" -o "%output_template%" %metadata_opts% %aria2c_args% %hw_accel_opts% "%link%" || (
    echo Download failed. Please check your internet connection and URL.
    call "%~dp0..\lib\error.bat" download_failed
    pause
    exit /b 1
)

echo Download completed successfully!
pause
exit /b 0

:live_stream
cls
echo ===================================================
echo              Live Stream Archiver
echo ===================================================
echo Note: This tool combines features of yt-dlp and ytarchive
echo       for optimal live stream handling
echo.
echo Features:
echo - Auto-retry on connection loss
echo - Proper live stream segmentation
echo - VOD-quality downloads
echo - Supports member streams (with cookies)
echo.
echo Download Method:
echo  1. ytarchive (Recommended for):
echo     - Ongoing live streams
echo     - Stream archiving from start
echo     - Better memory management
echo     - Automatic reconnection
echo.
echo  2. yt-dlp (Better for):
echo     - Already completed streams
echo     - Streams with chapters
echo     - Streams needing post-processing
echo     - Higher quality options
echo     - More post-processing
echo.
set /p "method=Select method (1-2): "

if "%method%"=="2" goto live_stream_ytdlp

REM Check for ytarchive
where ytarchive >nul 2>&1 || (
    echo Error: ytarchive not found
    echo This method requires ytarchive for optimal live stream handling
    echo Would you like to:
    echo  1. Use yt-dlp instead (good for VODs)
    echo  2. Return to menu
    choice /c 12 /n /m "Select option (1-2): "
    if errorlevel 2 exit /b 1
    goto live_stream_ytdlp
)

echo.
echo Select Quality:
echo  1. Best Quality    (max resolution + best audio)
echo  2. 1080p60        (1920x1080 @ 60fps)
echo  3. 1080p          (1920x1080 @ 30fps)
echo  4. 720p60         (1280x720 @ 60fps)
echo  5. 720p           (1280x720 @ 30fps)
echo  6. Audio Only     (Best audio quality)
echo.
echo Note: You can add fallback qualities using "/"
echo Example: 1080p60/1080p/720p60/best
echo.
set /p "quality=Select quality (1-6): "

REM Quality string with fallbacks
if "%quality%"=="1" set "quality_str=best"
if "%quality%"=="2" set "quality_str=1080p60/1080p/best"
if "%quality%"=="3" set "quality_str=1080p/720p60/best"
if "%quality%"=="4" set "quality_str=720p60/720p/best"
if "%quality%"=="5" set "quality_str=720p/best"
if "%quality%"=="6" set "quality_str=audio_only"

echo.
echo Additional Options:
echo  1. Download from start
echo  2. Wait for stream to start
echo  3. Download from current time
echo  4. Download with time range
set /p "opt=Select option (1-4): "

set "extra_args="
if "%opt%"=="1" set "extra_args=--live-from-start"
if "%opt%"=="2" set "extra_args=-w"
if "%opt%"=="3" set "extra_args=--live-from now"
if "%opt%"=="4" (
    echo Enter time range (e.g., 1h30m):
    set /p "timerange="
    set "extra_args=--capture-duration !timerange!"
)

REM Add cookies check for member streams
if exist "cookies.txt" (
    echo.
    echo Cookies file found. Use for members-only content?
    choice /c YN /n /m "(Y)es or (N)o? "
    if errorlevel 2 goto :skip_cookies
    set "extra_args=!extra_args! -c cookies.txt"
)
:skip_cookies

set /p "link=Enter stream URL: "
call "%~dp0..\utils\progress.bat" "live_ytarchive" "%link%" "%quality_str%" "!LIVE_OUT!"

ytarchive.exe --threads 3 --output "!LIVE_OUT!" %extra_args% "%link%" "%quality_str%" || (
    set "error_code=%errorlevel%"
    call "%~dp0..\lib\error.bat" handle_error
    exit /b 1
)

echo Download complete!
pause
exit /b 0

:live_stream_ytdlp
set /p "link=Enter stream URL: "
call "%~dp0..\utils\progress.bat" "live_ytdlp" "%link%" "best" "!LIVE_OUT!"

set "live_args=--live-from-start --wait-for-video 5-30 --retries infinite --concurrent-fragments 5"

REM Get stream info and set appropriate download profile
for /f "tokens=1" %%a in ('yt-dlp.exe --print filesize "%link%" 2^>nul') do (
    if not "%%a"=="" if not "%%a"=="NA" call "%~dp0..\config\settings.bat" :set_aria2c_profile "%%a"
)

yt-dlp.exe %ytdlp_base_args% ^
    %live_args% ^
    -f "bestvideo*+bestaudio/best" ^
    -o "!LIVE_OUT!" ^
    --write-thumbnail ^
    --embed-thumbnail ^
    --embed-metadata ^
    --embed-chapters ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "!CACHE_DIR!" ^
    "%link%" >nul 2>&1 || (
    set "error_code=%errorlevel%"
    call "%~dp0..\lib\error.bat" handle_error
    exit /b 1
)

echo Download complete!
pause
exit /b 0
