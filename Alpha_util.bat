@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title Advanced YouTube Downloader (Alpha Utility)
color 0b

REM Version info
set "VERSION=1.0.1"
set "LAST_UPDATED=2025-01"

REM Set up directory structure
set "BASE_DIR=%~dp0"
set "download_dir=%BASE_DIR%downloads"
set "TEMP_DIR=%download_dir%\.temp"
set "CACHE_DIR=%download_dir%\.cache"

REM Create directory structure
if not exist "%download_dir%" md "%download_dir%"
if not exist "%download_dir%\videos" md "%download_dir%\videos"
if not exist "%download_dir%\playlists" md "%download_dir%\playlists"
if not exist "%download_dir%\channels" md "%download_dir%\channels"
if not exist "%download_dir%\audio" md "%download_dir%\audio"
if not exist "%TEMP_DIR%" md "%TEMP_DIR%"
if not exist "%CACHE_DIR%" md "%CACHE_DIR%"

REM Set instance-specific temp directory
set "instance_id=%RANDOM%"
set "instance_temp=%TEMP_DIR%\%instance_id%"
md "%instance_temp%" 2>nul

REM Generate unique ID
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "instance_id=%datetime:~0,14%_%RANDOM%"
set "instance_temp=%TEMP%\ytdl_temp_%instance_id%"
md "%instance_temp%" 2>nul

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
set "format_selection=bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
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

REM Configure optimized download settings
set "ytdlp_base_args=--no-mtime --progress --no-warnings --no-continue --no-part"

REM Configure aria2c for faster downloads
set "aria2c_args=--downloader aria2c --downloader-args aria2c:-x16 -s16 -j16 -k1M --optimize-concurrent-downloads=true --file-allocation=none --continue=true --auto-file-renaming=false --allow-overwrite=true"

REM Configure ffmpeg for hardware acceleration
set "ffmpeg_args="
if "%hw_accel_available%"=="true" (
    set "ffmpeg_args=--postprocessor-args ffmpeg:-hwaccel !hw_accel! -hwaccel_device !hw_accel_device! -threads auto"
)

REM Configure output templates with better organization
set "video_template=!download_dir!\videos\%%(title)s [%%(id)s]\%%(title)s.%%(ext)s"
set "playlist_template=!download_dir!\playlists\%%(playlist_title)s\%%(playlist_index)02d - %%(title)s.%%(ext)s"
set "channel_template=!download_dir!\channels\%%(channel)s\%%(upload_date)s - %%(title)s.%%(ext)s"
set "audio_template=!download_dir!\audio\%%(title)s\%%(title)s.%%(ext)s"

REM Main menu loop
:menu
cls
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
if "%quality%"=="1" set "format_selection=bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
if "%quality%"=="2" set "format_selection=bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best"
if "%quality%"=="3" set "format_selection=bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best"

echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: !video_template!
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Download with all features enabled
yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "!video_template!" ^
    --write-description ^
    --write-thumbnail ^
    --convert-thumbnails webp ^
    --embed-thumbnail ^
    --embed-metadata ^
    --embed-chapters ^
    --write-auto-sub ^
    --sub-langs "en.*" ^
    --embed-subs ^
    --merge-output-format mp4 ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "!CACHE_DIR!" ^
    "%link%"

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
if "%quality%"=="1" set "format_selection=bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
if "%quality%"=="2" set "format_selection=bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best"
if "%quality%"=="3" set "format_selection=bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best"

echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: !playlist_template!
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
    -o "!playlist_template!" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "!CACHE_DIR!" ^
    "%link%"

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

if "%quality%"=="1" set "format_selection=bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
if "%quality%"=="2" set "format_selection=bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best"
if "%quality%"=="3" set "format_selection=bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best"

REM Create unique temp directory for this instance
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

set "channel_args="
if not "%limit%"=="" set "channel_args=--playlist-end %limit%"

REM Add before download commands
echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: %download_dir%
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Using optimized download settings for channel
set "output_template=%download_dir%\channels\%%(uploader)s\%%(title)s.%%(ext)s"

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
    "%link%"

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
echo • Output: %download_dir%
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
    -o "%audio_template%" ^
    "%link%"

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

REM Generate a unique ID for this instance
set "instance_id=%RANDOM%"

REM Create unique temp directory for this instance
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

REM Add before download commands
echo.
echo [Download Progress]
echo • URL: %link%
echo • Quality: %audio_ext%
echo • Output: %download_dir%
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Using optimized download settings for playlist audio
set "output_template=%download_dir%\playlists\%%(playlist)s\%%(playlist_index)s - %%(title)s.%%(ext)s"

yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "%instance_temp%" ^
    "%link%"

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
echo     - Completed streams/VODs
echo     - Streams with chapters
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
echo.
set /p "link=Enter stream URL: "

REM Generate unique instance ID
set "instance_id=%RANDOM%"
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

REM Enhanced live stream settings for yt-dlp
set "output_template=%download_dir%\live\%%(uploader)s\%%(upload_date)s_%%(title)s.%%(ext)s"

yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %aria2c_args% ^
    %ffmpeg_args% ^
    --cache-dir "%instance_temp%" ^
    "%link%"

REM Cleanup
rd /s /q "%TEMP%\ytdl_temp_%instance_id%" 2>nul

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
    "%link%"

:cleanup
REM Clean only this instance's temp directory
rd /s /q "%instance_temp%" 2>nul
exit /b 0

:error_handler
echo.
echo Error occurred: !error_message!
echo.
echo Common issues:
echo • Network connectivity problems
echo • Video unavailable or private
echo • Insufficient permissions
echo • Hardware acceleration issues
echo • Cookie/authentication required
echo.
choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
if errorlevel 3 goto cleanup
if errorlevel 2 goto menu
if errorlevel 1 goto :retry_download

:retry_download
echo Retrying download...
goto :%previous_operation%

:handle_exit
exit /b 0