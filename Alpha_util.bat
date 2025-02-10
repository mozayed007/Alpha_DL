@echo off
setlocal EnableDelayedExpansion EnableExtensions
chcp 65001 >nul 2>&1
title Advanced YouTube Downloader (Alpha Utility)
color 0b 2>nul

REM Version info
set "VERSION=1.0.1"
set "LAST_UPDATED=2025-01"

REM Disable all beeping and console sounds
for /f %%a in ('echo prompt $H ^| cmd') do set "BS=%%a"
set "BELL="
set "ConsolePid="
for /f "tokens=2 delims=;" %%a in ('tasklist /fi "imagename eq cmd.exe" /v /fo csv /nh ^| findstr /i /c:"Advanced YouTube Downloader"') do set "ConsolePid=%%~a"
if defined ConsolePid (
    nircmd.exe win settopmost title "Advanced YouTube Downloader" 0 >nul 2>&1
    nircmd.exe win setsize title "Advanced YouTube Downloader" 100 100 800 600 >nul 2>&1
)

REM Set up directory structure with short paths
set "BASE_DIR=%~dp0"
set "download_dir=%BASE_DIR%downloads"
set "TEMP_DIR=%download_dir%\.temp"
set "CACHE_DIR=%download_dir%\.cache"
set "LOG_DIR=%download_dir%\.logs"

REM Create directory structure silently
md "%download_dir%" 2>nul
md "%download_dir%\videos" 2>nul
md "%download_dir%\playlists" 2>nul
md "%download_dir%\channels" 2>nul
md "%download_dir%\audio" 2>nul
md "%download_dir%\live" 2>nul
md "%TEMP_DIR%" 2>nul
md "%CACHE_DIR%" 2>nul
md "%LOG_DIR%" 2>nul

REM Set instance-specific temp directory without output
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do set datetime=%%I
if not defined datetime (
    echo Error: Could not get system time
    set "datetime=00000000000000"
)
set "instance_id=%datetime:~0,14%_%RANDOM%"
set "instance_temp=%TEMP_DIR%\%instance_id%"
set "instance_log=%LOG_DIR%\%instance_id%.log"
md "%instance_temp%" 2>nul

REM Initialize error codes and messages
set "ERROR_NETWORK=1"
set "ERROR_UNAVAILABLE=2"
set "ERROR_PERMISSION=3"
set "ERROR_HW_ACCEL=4"
set "ERROR_ARIA2C=5"
set "ERROR_INIT=6"
set "ERROR_UNKNOWN=9"

REM Error handling function
:error_handler
set "error_msg="
if not defined error_code set "error_code=%ERROR_UNKNOWN%"
if "%error_code%"=="%ERROR_NETWORK%" set "error_msg=Network connectivity problem"
if "%error_code%"=="%ERROR_UNAVAILABLE%" set "error_msg=Video unavailable or private"
if "%error_code%"=="%ERROR_PERMISSION%" set "error_msg=Insufficient permissions"
if "%error_code%"=="%ERROR_HW_ACCEL%" set "error_msg=Hardware acceleration error"
if "%error_code%"=="%ERROR_ARIA2C%" set "error_msg=aria2c download error"
if "%error_code%"=="%ERROR_INIT%" set "error_msg=Initialization error"
if "%error_code%"=="%ERROR_UNKNOWN%" set "error_msg=Unknown error occurred"

REM Log error details with timestamp
echo ---------------------------------------- >> "%instance_log%"
echo Error: !error_msg! (Code: %error_code%) >> "%instance_log%"
echo Time: %date% %time% >> "%instance_log%"
echo Command: %cmdline% >> "%instance_log%"
echo Previous Operation: %previous_operation% >> "%instance_log%"
echo ---------------------------------------- >> "%instance_log%"

echo.
echo Error occurred: !error_msg! (Code: %error_code%)
echo Previous operation: %previous_operation%
echo See log file: %instance_log%

if "%error_code%"=="%ERROR_ARIA2C%" (
    echo.
    echo aria2c encountered an error
    echo Retrying download without aria2c...
    set "use_aria2c=false"
    set "aria2c_args="
    goto :retry_download
)

if "%hw_accel_available%"=="true" (
    echo.
    echo Hardware acceleration was enabled
    echo Retrying without hardware acceleration...
    set "hw_accel_available=false"
    set "ffmpeg_args="
    goto :retry_download
)

choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
if errorlevel 3 goto :cleanup
if errorlevel 2 goto :menu
if errorlevel 1 goto :retry_download

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

REM Default settings
set "use_sponsorblock=false"
set "use_aria2c=true"
set "embed_subs=true"
set "auto_subs=true"
set "embed_thumb=true"
set "embed_meta=true"
set "format_selection=bestvideo*+bestaudio/best"
set "quality_str=Best Quality"

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

REM Configure base arguments for yt-dlp with better progress and stability
set "ytdlp_base_args=--no-mtime --progress --console-title --newline --no-warnings --ignore-errors --no-call-home --no-check-certificate --quiet --no-progress"

REM Configure aria2c for stable downloads with optimized settings
set "aria2c_args=--external-downloader aria2c --external-downloader-args "aria2c:--optimize-concurrent-downloads=true --max-concurrent-downloads=3 --max-connection-per-server=16 --split=16 --min-split-size=1M --max-tries=10 --retry-wait=5 --connect-timeout=10 --timeout=10 --continue=true --allow-overwrite=true --auto-file-renaming=false --file-allocation=none --disable-ipv6=true --summary-interval=0 --console-log-level=error --quiet=true""

REM Configure output templates with better organization and safe filenames
set "video_template=%%(title).80s [%%(id)s].%%(ext)s"
set "playlist_template=%%(playlist_title).80s\%%(playlist_index)02d - %%(title).80s.%%(ext)s"
set "channel_template=%%(uploader)s\%%(upload_date)s - %%(title).80s [%%(id)s].%%(ext)s"
set "audio_template=%%(title).80s.%%(ext)s"
set "live_template=%%(uploader)s\%%(upload_date)s_%%(title).80s [LIVE].%%(ext)s"

REM Set base paths for different content types (using short paths to avoid length issues)
set "VIDEO_OUT=%download_dir%\videos\%video_template%"
set "PLAYLIST_OUT=%download_dir%\playlists\%playlist_template%"
set "CHANNEL_OUT=%download_dir%\channels\%channel_template%"
set "AUDIO_OUT=%download_dir%\audio\%audio_template%"
set "LIVE_OUT=%download_dir%\live\%live_template%"

REM Progress tracking function
:show_progress
echo [%date% %time%] Download Progress >> "%instance_log%"
echo ----------------------------------------
echo Content Type: %content_type%
echo Quality: %quality_str%
echo Hardware Acceleration: %hw_accel_available%
echo Output Directory: %download_dir%
echo.
echo Progress will be logged to: %instance_log%
echo Press Q to quit, P to pause
echo ----------------------------------------

REM Configure ffmpeg for hardware acceleration
set "ffmpeg_args="
if "%hw_accel_available%"=="true" (
    set "ffmpeg_args=--postprocessor-args ffmpeg:-hwaccel !hw_accel! -hwaccel_device !hw_accel_device! -threads auto"
)

REM Main menu loop
:menu
cls
REM Save error level before cls
set "last_error=%errorlevel%"

REM Clear previous error if menu is reached normally
if "%previous_operation%"=="" set "error_code="

REM Show error message if coming from an error
if defined error_code (
    echo.
    echo Last error: !error_msg! (Code: !error_code!)
    echo See log file: !instance_log!
    echo.
)

echo ══════════════════════════════════════════════════════
echo         Advanced YouTube Downloader v%VERSION%        
echo ══════════════════════════════════════════════════════
echo.
echo [Basic Downloads]
echo  1. Single Video         5. Live Stream
echo  2. Playlist             6. Custom Format
echo  3. Channel              7. Extract Audio
echo  4. Audio Only           8. Batch Download
echo.
echo [Advanced Features]
echo  9. Show Video Info     11. Download Thumbnail
echo  10. List Formats       12. Download Subtitles
echo.
echo [Settings]
echo  13. Download Directory  16. Network Settings
echo  14. Quality Settings    17. Hardware Accel
echo  15. Feature Toggle      18. Cookie Settings
echo  19. Update yt-dlp
echo.
echo  20. Exit
echo.
echo Current Settings:
echo • Directory: !download_dir!
echo • Format: !format_selection!
echo • Hardware: !hw_accel_available! (!hw_accel!)
echo • Features:
echo   ├─ SponsorBlock: !use_sponsorblock!
echo   ├─ Aria2c: !use_aria2c!
echo   ├─ Subtitles: !embed_subs!
echo   ├─ Thumbnails: !embed_thumb!
echo   └─ Metadata: !embed_meta!
echo.
echo Tips:
echo • Use aria2c for faster downloads
echo • Check cookies for member-only content
echo • Use ytarchive for live streams
echo ══════════════════════════════════════════════════════
echo.

set /p "choice=Enter your choice (1-20): "

if "%choice%"=="" goto error
if %choice% LSS 1 goto error
if %choice% GTR 20 goto error

if "%choice%"=="1" goto download_video
if "%choice%"=="2" goto download_playlist
if "%choice%"=="3" goto download_channel
if "%choice%"=="4" goto audio_only
if "%choice%"=="5" goto live_stream
if "%choice%"=="6" goto custom_format
if "%choice%"=="7" goto extract_audio
if "%choice%"=="8" goto batch_download
if "%choice%"=="9" goto show_info
if "%choice%"=="10" goto list_formats
if "%choice%"=="11" goto download_thumb
if "%choice%"=="12" goto download_subs
if "%choice%"=="13" goto change_directory
if "%choice%"=="14" goto quality_settings
if "%choice%"=="15" goto toggle_features
if "%choice%"=="16" goto network_settings
if "%choice%"=="17" goto hw_accel_menu
if "%choice%"=="18" goto cookie_settings
if "%choice%"=="19" goto update_ytdlp
if "%choice%"=="20" goto handle_exit

:download_video
set "previous_operation=download_video"
cls
echo ===================================================
echo              Download Single Video
echo ===================================================
echo.
echo Select Quality:
echo  1. Best Quality   (max resolution/bitrate + best audio)
echo  2. 1080p         (FHD)
echo  3. 720p          (HD)
echo.
set /p "quality=Select quality (1-3): "
set /p "link=Enter video URL: "

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

echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: !VIDEO_OUT!
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Download with all features enabled
yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "!VIDEO_OUT!" ^
    --write-thumbnail ^
    --embed-thumbnail ^
    --embed-metadata ^
    --embed-chapters ^
    --write-sub ^
    --sub-langs "en.*" ^
    --embed-subs ^
    --merge-output-format "mp4" ^
    --no-keep-fragments ^
    --fragment-retries 10 ^
    --retry-sleep 5 ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "!CACHE_DIR!" ^
    "%link%" >nul 2>&1 || (
    set "error_code=%errorlevel%"
    goto :error_handler
)

REM Cleanup temp directory
rd /s /q "%instance_temp%" 2>nul

if errorlevel 1 (
    echo.
    echo Error occurred during download
    echo Common issues:
    echo - Network connectivity problems
    echo - Video unavailable or private
    echo - Insufficient permissions
    echo - Hardware acceleration issues
    
    if "%hw_accel_available%"=="true" (
        echo.
        echo Hardware acceleration was enabled
        echo Retrying without hardware acceleration...
        set "hw_accel_available=false"
        set "ffmpeg_args="
        goto :retry_download
    )
    
    echo.
    choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
    if errorlevel 3 goto clean_exit
    if errorlevel 2 goto menu
    if errorlevel 1 goto :retry_download
)

echo Download complete!
pause
goto menu

:download_playlist
set "previous_operation=download_playlist"
cls
echo ===================================================
echo              Download Playlist
echo ===================================================
echo.
echo Select Quality:
echo  1. Best Quality   (max resolution + best audio)
echo  2. 1080p         (FHD)
echo  3. 720p          (HD)
echo.
set /p "quality=Select quality (1-3): "
set /p "link=Enter playlist URL: "

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

echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: !PLAYLIST_OUT!
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Additional playlist arguments
set "playlist_args=--yes-playlist --playlist-random --ignore-errors --no-abort-on-error"

yt-dlp.exe %ytdlp_base_args% ^
    %playlist_args% ^
    -f "%format_selection%" ^
    -o "!PLAYLIST_OUT!" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "!CACHE_DIR!" ^
    "%link%" >nul 2>&1 || (
    set "error_code=%errorlevel%"
    goto :error_handler
)

REM Cleanup temp directory
rd /s /q "%instance_temp%" 2>nul

if errorlevel 1 (
    echo.
    echo Error occurred during download
    echo Common issues:
    echo - Network connectivity problems
    echo - Video unavailable or private
    echo - Insufficient permissions
    echo - Hardware acceleration issues
    
    if "%hw_accel_available%"=="true" (
        echo.
        echo Hardware acceleration was enabled
        echo Retrying without hardware acceleration...
        set "hw_accel_available=false"
        set "ffmpeg_args="
        goto :retry_download
    )
    
    echo.
    choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
    if errorlevel 3 goto clean_exit
    if errorlevel 2 goto menu
    if errorlevel 1 goto :retry_download
)

echo Download complete!
pause
goto menu

:download_channel
set "previous_operation=download_channel"
cls
echo ===================================================
echo              Download Channel
echo ===================================================
echo.
echo Select Quality:
echo  1. Best Quality   (max resolution/bitrate + best audio)
echo  2. 1080p         (FHD)
echo  3. 720p          (HD)
echo.
set /p "quality=Select quality (1-3): "
set /p "link=Enter channel URL: "
set /p "limit=Enter number of videos to download (optional, press Enter for all): "

REM Generate a unique ID for this instance
set "instance_id=%RANDOM%"

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

REM Create unique temp directory for this instance
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

set "channel_args="
if not "%limit%"=="" set "channel_args=--playlist-end %limit%"

REM Add before download commands
echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: !CHANNEL_OUT!
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Using optimized download settings for channel
set "output_template=!CHANNEL_OUT!"

REM Channel monitor specific arguments
set "monitor_args=--download-archive "%monitor_archive%" --playlist-reverse --no-overwrites --continue"

REM For channel monitoring
yt-dlp.exe %ytdlp_base_args% ^
    %monitor_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "%instance_temp%" ^
    %channel_args% ^
    "%link%" >nul 2>&1 || (
    set "error_code=%errorlevel%"
    goto :error_handler
)

REM Cleanup temp directory
rd /s /q "%TEMP%\ytdl_temp_%instance_id%" 2>nul

if errorlevel 1 (
    echo.
    echo Error occurred during download
    echo Common issues:
    echo - Network connectivity problems
    echo - Video unavailable or private
    echo - Insufficient permissions
    echo - Hardware acceleration issues
    
    if "%hw_accel_available%"=="true" (
        echo.
        echo Hardware acceleration was enabled
        echo Retrying without hardware acceleration...
        set "hw_accel_available=false"
        set "ffmpeg_args="
        goto :retry_download
    )
    
    echo.
    choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
    if errorlevel 3 goto clean_exit
    if errorlevel 2 goto menu
    if errorlevel 1 goto :retry_download
)

echo Download complete!
pause
goto menu

:audio_only
cls
echo ===================================================
echo              Download Audio Only
echo ===================================================
echo.
echo 1. Single Audio
echo 2. Playlist Audio
echo.
set /p "choice=Enter choice (1-2): "

if "%choice%"=="2" goto audio_playlist

REM Generate a unique ID for this instance
set "instance_id=%RANDOM%"

REM Create unique temp directory for this instance
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

set /p "link=Enter the URL: "
set /p "audio_format=Select audio format (1=mp3, 2=m4a, 3=wav, 4=opus): "
set "audio_ext=m4a"
if "%audio_format%"=="1" set "audio_ext=mp3"
if "%audio_format%"=="3" set "audio_ext=wav"
if "%audio_format%"=="4" set "audio_ext=opus"

REM Add before download commands
echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %audio_ext%
echo • Output: !AUDIO_OUT!
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM For audio downloads
set "audio_format_args=--extract-audio --audio-format %audio_ext% --audio-quality 0"
set "audio_post_args=--embed-thumbnail --embed-metadata --postprocessor-args "ffmpeg:-threads 3""

yt-dlp.exe %ytdlp_base_args% ^
    %audio_format_args% ^
    %audio_post_args% ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "%instance_temp%" ^
    -o "!AUDIO_OUT!" ^
    "%link%" >nul 2>&1 || (
    set "error_code=%errorlevel%"
    goto :error_handler
)

REM Cleanup temp directory
rd /s /q "%instance_temp%" 2>nul

if errorlevel 1 (
    echo.
    echo Error occurred during download
    echo Common issues:
    echo - Network connectivity problems
    echo - Video unavailable or private
    echo - Insufficient permissions
    echo - Hardware acceleration issues
    
    if "%hw_accel_available%"=="true" (
        echo.
        echo Hardware acceleration was enabled
        echo Retrying without hardware acceleration...
        set "hw_accel_available=false"
        set "ffmpeg_hw_flags="
        goto :retry_download
    )
    
    echo.
    choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
    if errorlevel 3 goto clean_exit
    if errorlevel 2 goto menu
    if errorlevel 1 goto :retry_download
)

echo Download complete!
pause
goto menu

:audio_playlist
set "previous_operation=audio_playlist"
set /p "link=Enter playlist URL: "
set /p "audio_format=Select audio format (1=mp3, 2=m4a, 3=wav, 4=opus): "
set "audio_ext=m4a"
if "%audio_format%"=="1" set "audio_ext=mp3"
if "%audio_format%"=="3" set "audio_ext=wav"
if "%audio_format%"=="4" set "audio_ext=opus"

REM Generate unique instance ID
set "instance_id=%RANDOM%"
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

REM Add before download commands
echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %audio_ext%
echo • Output: !PLAYLIST_OUT!
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Using optimized download settings for playlist audio
set "output_template=!PLAYLIST_OUT!"

yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "%instance_temp%" ^
    "%link%" >nul 2>&1 || (
    set "error_code=%errorlevel%"
    goto :error_handler
)

REM Cleanup temp directory
rd /s /q "%instance_temp%" 2>nul

if errorlevel 1 (
    echo.
    echo Error occurred during download
    echo Common issues:
    echo - Network connectivity problems
    echo - Video unavailable or private
    echo - Insufficient permissions
    echo - Hardware acceleration issues
    
    if "%hw_accel_available%"=="true" (
        echo.
        echo Hardware acceleration was enabled
        echo Retrying without hardware acceleration...
        set "hw_accel_available=false"
        set "ffmpeg_hw_flags="
        goto :retry_download
    )
    
    echo.
    choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
    if errorlevel 3 goto clean_exit
    if errorlevel 2 goto menu
    if errorlevel 1 goto :retry_download
)

echo Download complete!
pause
goto menu

:live_stream
set "previous_operation=live_stream"
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
    if errorlevel 2 goto menu
    goto live_stream_ytdlp
)

REM Add quality selection for ytarchive
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

:live_stream_ytdlp
cls
echo ===================================================
echo           Live Stream Download (yt-dlp)
echo ===================================================
echo Note: This method is better for:
echo - Already completed streams
echo - Streams with chapters
echo - Streams needing post-processing
echo - Higher quality options
echo - More post-processing
echo.
set /p "link=Enter stream URL: "

REM Generate unique instance ID
set "instance_id=%RANDOM%"
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

REM Enhanced live stream settings for yt-dlp
set "output_template=!LIVE_OUT!"

yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "%instance_temp%" ^
    "%link%" >nul 2>&1 || (
    set "error_code=%errorlevel%"
    goto :error_handler
)

:monitor_channel
REM Add instance-specific monitor files
set "monitor_archive=%instance_temp%\archive.txt"
set "monitor_log=%instance_temp%\monitor.log"

REM Modify yt-dlp monitor command:
set "monitor_args=--download-archive "%monitor_archive%" --playlist-reverse --no-overwrites --continue"

REM For channel monitoring
yt-dlp.exe %ytdlp_base_args% ^
    %monitor_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "%instance_temp%" ^
    "%link%" >nul 2>&1 || (
    set "error_code=%errorlevel%"
    goto :error_handler
)

:cleanup
REM Clean only this instance's temp directory
rd /s /q "%instance_temp%" 2>nul
exit /b 0

:error_handler
echo.
echo Error occurred during download (Code: !error_code!)
echo.
echo Common issues:
echo • Network connectivity problems
echo • Video unavailable or private
echo • Insufficient permissions
echo • Hardware acceleration issues
echo • Format not available
echo • Region restrictions
echo.

if "%error_code%"=="%ERROR_ARIA2C%" (
    echo.
    echo aria2c encountered an error
    echo Retrying download without aria2c...
    set "use_aria2c=false"
    set "aria2c_args="
    goto :retry_download
)

if "%hw_accel_available%"=="true" (
    echo.
    echo Hardware acceleration was enabled
    echo Retrying without hardware acceleration...
    set "hw_accel_available=false"
    set "ffmpeg_args="
    goto :retry_download
)

choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
if errorlevel 3 goto :cleanup
if errorlevel 2 goto :menu
if errorlevel 1 goto :retry_download

:retry_download
echo.
echo Retrying download with modified settings...
echo [%date% %time%] Retrying download >> "%instance_log%"
goto :%previous_operation%

:cleanup
rd /s /q "%instance_temp%" 2>nul
if "%1"=="exit" exit /b %error_code%
goto :menu

:error
if defined previous_operation goto :%previous_operation%
goto :menu