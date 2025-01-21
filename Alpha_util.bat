@echo off
setlocal EnableDelayedExpansion
title Advanced YouTube Downloader (Alpha Utility)
color 0b

REM Add version and last updated info
set "VERSION=1.0.1"
set "LAST_UPDATED=2024-03"

REM Add a loading screen
echo ===================================================
echo          Loading Advanced YouTube Downloader
echo                  Version %VERSION%
echo ===================================================
echo.
echo Checking dependencies...
echo.

:generate_unique_id
REM Generate truly unique instance ID using timestamp and random
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "instance_id=%datetime:~0,14%_%RANDOM%"

REM Create instance-specific temp directory
set "instance_temp=%TEMP%\ytdl_temp_%instance_id%"
md "%instance_temp%" 2>nul

REM Create instance-specific settings file
set "instance_settings=%instance_temp%\settings.txt"

REM Improve dependency check with more user-friendly output
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

REM Add similar checks for aria2c and ytarchive

if not "!MISSING_DEPS!"=="" (
    echo Error: Missing required programs:!MISSING_DEPS!
    echo Please ensure these programs are installed and in your PATH
    echo Download links:
    echo - yt-dlp: https://github.com/yt-dlp/yt-dlp/releases
    echo - ffmpeg: https://ffmpeg.org/download.html
    echo - aria2c: https://github.com/aria2/aria2/releases
    echo - ytarchive: https://github.com/Kethsar/ytarchive/releases
    pause
    exit /b 1
)

REM Create download directory if it doesn't exist
if not defined download_dir set "download_dir=%~dp0downloads"
:create_download_dir
REM Safe directory creation with retries
set "max_retries=5"
set "retry_count=0"

:retry_create_dir
if exist "!download_dir!" goto :dir_exists
md "!download_dir!" 2>nul
if errorlevel 1 (
    set /a "retry_count+=1"
    if !retry_count! lss !max_retries! (
        timeout /t 1 /nobreak >nul
        goto :retry_create_dir
    )
    echo Error: Could not create download directory
    goto :handle_exit
)

:dir_exists

REM Initialize settings with defaults
if not defined use_sponsorblock set "use_sponsorblock=false"
if not defined use_aria2c set "use_aria2c=true"
if not defined embed_subs set "embed_subs=true"
if not defined auto_subs set "auto_subs=true"
if not defined embed_thumb set "embed_thumb=true"
if not defined embed_meta set "embed_meta=true"

REM Set default download directory to the script's current folder
set "download_dir=%~dp0"
set "config_file=%~dp0yt-dlp.conf"

REM Default settings
set "use_aria2c=true"
set "use_sponsorblock=true"
set "embed_subs=true"
set "embed_thumb=true"
set "embed_meta=true"
set "auto_subs=true"
set "cookies_file="
set "use_proxy="

REM Format definitions with improved compatibility
set "format_best=bestvideo*+bestaudio/best"
set "format_1080=bestvideo[height<=1080]+bestaudio/best[height<=1080]/best"
set "format_720=bestvideo[height<=720]+bestaudio/best[height<=720]/best"

REM Initialize hardware acceleration settings by default
call :detect_hw_accel

REM Add this to the initial settings block
if not defined hw_accel_available set "hw_accel_available=false"
if not defined hw_accel set "hw_accel="
if not defined hw_accel_device set "hw_accel_device="
if not defined ffmpeg_hw_flags set "ffmpeg_hw_flags="

REM Handle Ctrl+C gracefully
if "%~1"=="HANDLED" goto :mainStart
start "" /b "%~f0" HANDLED %*
exit /b

:mainStart
goto menu

:handle_exit
echo.
choice /c MQ /n /m "Return to Menu (M) or Quit (Q)? "
if errorlevel 2 goto clean_exit
if errorlevel 1 goto menu

:clean_exit
echo.
echo Cleaning up and exiting...
timeout /t 1 /nobreak >nul
goto cleanup

:error
echo Invalid input. Please try again.
timeout /t 2 /nobreak >nul
goto menu

:update_ytdlp
cls
echo Updating yt-dlp...
yt-dlp.exe -U
pause
goto menu
:handle_exit
echo.
choice /c MQ /n /m "Exit (Q) or return to Menu (M)? "
if errorlevel 2 goto clean_exit
if errorlevel 1 goto menu

:clean_exit
echo.
echo Cleaning up and exiting...
timeout /t 1 /nobreak >nul
goto cleanup
:menu
cls
echo ╔══════════════════════════════════════════════════╗
echo ║         Advanced YouTube Downloader v%VERSION%    ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo [Download Options]
echo  1 │ Single Video     4 │ Audio Only
echo  2 │ Playlist         5 │ Live Stream
echo  3 │ Channel          6 │ Custom Format
echo.
echo [Settings]
echo  7 │ Download Dir     10 │ Network Settings
echo  8 │ Quality          11 │ Hardware Accel
echo  9 │ Features         12 │ Update Tools
echo.
echo Current Settings:
echo • Directory: !download_dir!
echo • Hardware Accel: !hw_accel_available! (!hw_accel!)
echo • Format: !format_selection!
echo.
echo  [Download Options]
echo  1. Download Single Video (Best for regular videos)
echo  2. Download Playlist    (Optimized for multiple videos)
echo  3. Download Channel    (Full channel archiving)
echo  4. Download Audio Only (Music/Audio extraction)
echo  5. Download Live Stream (Live/VOD with ytarchive)
echo  6. Download with Custom Format (Advanced users)
echo  7. Extract Audio from Video File (Local files)
echo.
echo  [Configuration]
echo  8. Change Download Directory
echo     Current: !download_dir!
echo  9. Format Selection Options
echo     Current: !format_selection!
echo  10. Toggle Features
echo      - SponsorBlock: !use_sponsorblock!
echo      - Aria2c: !use_aria2c!
echo      - Subtitles: !embed_subs!
echo      - Thumbnails: !embed_thumb!
echo      - Metadata: !embed_meta!
echo  11. Network Settings (Proxy/Speed limits)
echo  12. Cookie Configuration (For private/member videos)
echo  13. Update yt-dlp (Check for new version)
echo.
echo  [Hardware Acceleration]
if "%hw_accel_available%"=="true" (
    echo      Status: Enabled (!hw_accel! - !hw_accel_device!)
) else (
    echo      Status: Disabled (CPU encoding)
)
echo.
echo  [Utilities]
echo  14. Show Video Information (Format details)
echo  15. List Available Formats (Resolution/codecs)
echo  16. Download Subtitles Only
echo  17. Download Thumbnail Only
echo  18. Batch Download from File (URL list)
echo.
echo  19. Hardware Acceleration Settings
echo.
echo  20. Exit
echo.
echo Tips:
echo - Use aria2c for faster downloads
echo - Check cookies for member-only content
echo - Use ytarchive for live streams
echo ===================================================
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
if "%choice%"=="8" goto change_directory
if "%choice%"=="9" goto format_menu
if "%choice%"=="10" goto toggle_features
if "%choice%"=="11" goto network_settings
if "%choice%"=="12" goto cookie_settings
if "%choice%"=="13" goto update_ytdlp
if "%choice%"=="14" goto show_info
if "%choice%"=="15" goto list_formats
if "%choice%"=="16" goto download_subs
if "%choice%"=="17" goto download_thumb
if "%choice%"=="18" goto batch_download
if "%choice%"=="19" goto hw_accel_menu
if "%choice%"=="20" goto end

:download_video
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

REM Updated format selections with unique temp directories
if "%quality%"=="1" set "format_selection=bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
if "%quality%"=="2" set "format_selection=bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best"
if "%quality%"=="3" set "format_selection=bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best"

REM Create unique temp directory for this instance
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

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

REM For yt-dlp downloads:
set "ytdlp_hw_args="
if "%hw_accel_available%"=="true" (
    set "ytdlp_hw_args=--postprocessor-args "ffmpeg:-hwaccel !hw_accel! -hwaccel_device !hw_accel_device! -hwaccel_output_format !hw_accel!""
)

REM Using optimized download settings matching playlist performance
set "ytdlp_base_args=--no-mtime --ignore-errors --no-continue --no-overwrites"
set "ytdlp_aria_args=--downloader aria2c --downloader-args "aria2c:-x 16 -k 1M -s 16 -j 16 --optimize-concurrent-downloads=true --file-allocation=none --async-dns=false --continue=true --allow-overwrite=true --auto-file-renaming=false""
set "ytdlp_format_args=--merge-output-format mp4 --no-keep-fragments --buffer-size 16M --http-chunk-size 10M"
set "ytdlp_concurrent_args=--concurrent-fragments 5 -N 5"

REM For video downloads (single/playlist/channel):
set "output_template=%download_dir%\%%(title)s.%%(ext)s"

yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %ytdlp_aria_args% ^
    %ytdlp_format_args% ^
    %ytdlp_concurrent_args% ^
    %ytdlp_hw_args% ^
    --cache-dir "%instance_temp%" ^
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

:download_playlist
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

REM Generate a unique ID for this instance
set "instance_id=%RANDOM%"

if "%quality%"=="1" set "format_selection=bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
if "%quality%"=="2" set "format_selection=bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4][height<=1080]/best"
if "%quality%"=="3" set "format_selection=bestvideo[ext=mp4][height<=720]+bestaudio[ext=m4a]/best[ext=mp4][height<=720]/best"

REM Create unique temp directory for this instance
md "%TEMP%\ytdl_temp_%instance_id%" 2>nul

REM Additional playlist arguments
set "playlist_args=--yes-playlist --playlist-random --ignore-errors --no-abort-on-error"

REM For playlist downloads
yt-dlp.exe %ytdlp_base_args% ^
    %playlist_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %ytdlp_aria_args% ^
    %ytdlp_format_args% ^
    %ytdlp_concurrent_args% ^
    %ytdlp_hw_args% ^
    --cache-dir "%instance_temp%" ^
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

:download_channel
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
set "output_template=%download_dir%\%%(uploader)s\%%(title)s.%%(ext)s"

REM Channel monitor specific arguments
set "monitor_args=--download-archive "%monitor_archive%" --playlist-reverse --no-overwrites --continue"

REM For channel monitoring
yt-dlp.exe %ytdlp_base_args% ^
    %monitor_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %ytdlp_aria_args% ^
    %ytdlp_format_args% ^
    %ytdlp_concurrent_args% ^
    %ytdlp_hw_args% ^
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
    %ytdlp_aria_args% ^
    %ytdlp_concurrent_args% ^
    %ytdlp_hw_args% ^
    --cache-dir "%instance_temp%" ^
    -o "%output_template%" ^
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

:audio_playlist
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
set "output_template=%download_dir%\%%(playlist)s\%%(playlist_index)s - %%(title)s.%%(ext)s"

yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %ytdlp_aria_args% ^
    %ytdlp_format_args% ^
    %ytdlp_concurrent_args% ^
    %ytdlp_hw_args% ^
    --cache-dir "%instance_temp%" ^
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
set "output_template=%download_dir%\%%(uploader)s\%%(upload_date)s_%%(title)s.%%(ext)s"

yt-dlp.exe %ytdlp_base_args% ^
    -f "%format_selection%" ^
    -o "%output_template%" ^
    --write-auto-sub --embed-subs --embed-thumbnail --embed-metadata ^
    %ytdlp_aria_args% ^
    %ytdlp_format_args% ^
    %ytdlp_concurrent_args% ^
    %ytdlp_hw_args% ^
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
    %ytdlp_aria_args% ^
    %ytdlp_format_args% ^
    %ytdlp_concurrent_args% ^
    %ytdlp_hw_args% ^
    --cache-dir "%instance_temp%" ^
    "%link%"

:cleanup
REM Clean only this instance's temp directory
rd /s /q "%instance_temp%" 2>nul

REM Save settings to instance-specific file
(
    echo use_sponsorblock=!use_sponsorblock!
    echo use_aria2c=!use_aria2c!
    echo embed_subs=!embed_subs!
    echo embed_thumb=!embed_thumb!
    echo embed_meta=!embed_meta!
    echo download_dir=!download_dir!
    echo format_selection=!format_selection!
    echo hw_accel_available=!hw_accel_available!
    echo hw_accel=!hw_accel!
    echo hw_accel_device=!hw_accel_device!
) > "%instance_settings%"

exit /b 0

:format_menu
cls
echo ===================================================
echo            Format Selection Options
echo ===================================================
echo 1. Best Quality (Video + Audio)
echo 2. Maximum 4K (2160p)
echo 3. Maximum 1080p
echo 4. Maximum 720p
echo 5. Custom Format Code
echo.
set /p "format_choice=Select format (1-5): "

if "%format_choice%"=="1" set "format_selection=bestvideo+bestaudio/best"
if "%format_choice%"=="2" set "format_selection=bestvideo[height<=2160]+bestaudio/best"
if "%format_choice%"=="3" set "format_selection=bestvideo[height<=1080]+bestaudio/best"
if "%format_choice%"=="4" set "format_selection=bestvideo[height<=720]+bestaudio/best"
if "%format_choice%"=="5" (
    echo Enter custom format code:
    echo Example: bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]
    set /p "format_selection="
)

:network_settings
cls
echo ===================================================
echo            Network Settings
echo ===================================================
echo 1. Set Download Speed Limit
echo 2. Configure Proxy
echo 3. Set Retries
echo 4. Back to Menu
echo.
set /p "net_choice=Select option (1-4): "

if "%net_choice%"=="1" (
    set /p "speed_limit=Enter speed limit (e.g., 1M, 500K): "
    set "aria2c_args=!aria2c_args! --max-download-limit=%speed_limit%"
)

:cookie_settings
cls
echo ===================================================
echo            Cookie Configuration
echo ===================================================
echo 1. Select Cookie File
echo 2. Remove Cookie File
echo 3. Back to Menu
echo.
set /p "cookie_choice=Select option (1-3): "

if "%cookie_choice%"=="1" (
    set /p "cookies_file=Enter path to cookies.txt: "
    if not exist "!cookies_file!" (
        echo Error: File not found
        pause
        goto cookie_settings
    )
)

:detect_hw_accel
echo Detecting hardware acceleration capabilities...
set "hw_accel="
set "hw_accel_device="
set "hw_accel_available=false"

REM Check for NVIDIA GPU (NVENC)
nvidia-smi >nul 2>&1
if not errorlevel 1 (
    set "has_nvidia=true"
    set "hw_accel=nvenc"
    set "hw_accel_device=cuda"
    set "hw_accel_available=true"
) else (
    set "has_nvidia=false"
)

REM Check for Intel QuickSync
powershell -Command "Get-WmiObject Win32_VideoController | Where-Object {$_.Name -like '*Intel*'}" >nul 2>&1
if not errorlevel 1 (
    set "has_intel=true"
    if not defined hw_accel (
        set "hw_accel=qsv"
        set "hw_accel_device=qsv"
        set "hw_accel_available=true"
    )
) else (
    set "has_intel=false"
)

REM Check for AMD GPU (AMF)
powershell -Command "Get-WmiObject Win32_VideoController | Where-Object {$_.Name -like '*AMD*' -or $_.Name -like '*Radeon*'}" >nul 2>&1
if not errorlevel 1 (
    set "has_amd=true"
    if not defined hw_accel (
        set "hw_accel=amf"
        set "hw_accel_device=opencl"
        set "hw_accel_available=true"
    )
) else (
    set "has_amd=false"
)

REM Set ffmpeg flags based on available hardware
if "%hw_accel_available%"=="true" (
    set "ffmpeg_hw_flags=-hwaccel !hw_accel! -hwaccel_device !hw_accel_device!"
) else (
    set "ffmpeg_hw_flags="
)

REM For ytarchive:
set "ytarchive_hw_args="
if "%hw_accel_available%"=="true" (
    set "ytarchive_hw_args=--ffmpeg-path "ffmpeg -hwaccel !hw_accel! -hwaccel_device !hw_accel_device! -hwaccel_output_format !hw_accel!""
)

REM Standard optimized yt-dlp arguments for all download types
set "ytdlp_base_args=--no-mtime --ignore-errors --no-continue --no-overwrites"
set "ytdlp_aria_args=--downloader aria2c --downloader-args "aria2c:-x 16 -k 1M -s 16 -j 16 --optimize-concurrent-downloads=true --file-allocation=none --async-dns=false --continue=true --allow-overwrite=true --auto-file-renaming=false""
set "ytdlp_format_args=--merge-output-format mp4 --no-keep-fragments --buffer-size 16M --http-chunk-size 10M"
set "ytdlp_concurrent_args=--concurrent-fragments 5 -N 5"

REM Standard optimized ytarchive arguments
set "ytarchive_base_args=--threads 3 --no-frag-files --merge --vp9 -k -t"
set "ytarchive_retry_args=--retry-stream 60 --retry-frags 10"
set "ytarchive_format_args=--add-metadata --write-description --write-thumbnail"

REM Hardware acceleration integration
if "%hw_accel_available%"=="true" (
    set "ytdlp_hw_args=--postprocessor-args "ffmpeg:-hwaccel !hw_accel! -hwaccel_device !hw_accel_device! -hwaccel_output_format !hw_accel!""
    set "ytarchive_hw_args=--ffmpeg-path "ffmpeg -hwaccel !hw_accel! -hwaccel_device !hw_accel_device! -hwaccel_output_format !hw_accel!""
) else (
    set "ytdlp_hw_args="
    set "ytarchive_hw_args="
)

REM For live streams with ytarchive:
set "output_template=%download_dir%\%%(title)s.%%(ext)s"

ytarchive.exe %ytarchive_base_args% ^
    %ytarchive_retry_args% ^
    %ytarchive_format_args% ^
    %ytarchive_hw_args% ^
    -o "%output_template%" ^
    "%link%" %quality_str%

:hw_accel_menu
cls
echo ===================================================
echo         Hardware Acceleration Settings
echo ===================================================
echo Current Status:
if "%hw_accel_available%"=="true" (
    echo Hardware Acceleration: Enabled
    echo Type: !hw_accel! (!hw_accel_device!)
) else (
    echo Hardware Acceleration: Disabled
)
echo.
echo Available Options:
echo 1. Auto-detect and configure (Recommended)
echo 2. Force CPU encoding (No hardware acceleration)
echo 3. Show hardware information
echo 4. Back to menu
echo.
set /p "hw_choice=Select option (1-4): "

if "%hw_choice%"=="1" goto detect_hw_accel
if "%hw_choice%"=="2" (
    set "hw_accel_available=false"
    set "hw_accel="
    set "hw_accel_device="
    set "ffmpeg_hw_flags="
    echo Hardware acceleration disabled
    pause
)
if "%hw_choice%"=="3" (
    echo.
    echo Hardware Information:
    echo - NVIDIA GPU: !has_nvidia!
    echo - Intel QuickSync: !has_intel!
    echo - AMD GPU: !has_amd!
    echo.
    echo Current Configuration:
    echo - Hardware Acceleration: !hw_accel_available!
    echo - Acceleration Type: !hw_accel!
    echo - Device: !hw_accel_device!
    pause
)
if "%hw_choice%"=="4" goto menu

:handle_error
echo.
echo ╔══════════════════════════════════════════════════╗
echo ║                   Error Occurred                  ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo Error Details:
echo • Code: %errorlevel%
echo • Type: %error_type%
echo.
echo Possible Solutions:
echo 1. Check internet connection
echo 2. Verify URL is accessible
echo 3. Check available disk space
echo 4. Try without hardware acceleration
echo 5. Check for tool updates
echo.

:show_help
cls
echo ╔══════════════════════════════════════════════════╗
echo ║                     Help Guide                    ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo Common Tasks:
echo • Download Video: Option 1 - Best for single videos
echo • Download Playlist: Option 2 - Optimized for multiple videos
echo • Extract Audio: Option 4 - Convert videos to MP3/M4A
echo • Live Streams: Option 5 - Use ytarchive for best results
echo.
echo Tips:
echo • Use hardware acceleration for faster processing
echo • Enable aria2c for faster downloads
echo • Check cookies.txt for member-only content
echo • Use quality presets for consistent downloads
echo.

:show_status
echo.
echo Current Status:
echo • Download Speed: %current_speed%
echo • Progress: %progress%%
echo • ETA: %eta%
echo • File Size: %size%
echo.

:save_config
(
    echo VERSION=%VERSION%
    echo download_dir=!download_dir!
    echo use_sponsorblock=!use_sponsorblock!
    echo use_aria2c=!use_aria2c!
    echo embed_subs=!embed_subs!
    echo embed_thumb=!embed_thumb!
    echo embed_meta=!embed_meta!
    echo hw_accel_available=!hw_accel_available!
    echo hw_accel=!hw_accel!
    echo hw_accel_device=!hw_accel_device!
    echo format_selection=!format_selection!
) > "config.txt"

:download_options
echo Additional Options:
echo 1. Enable SponsorBlock    [%use_sponsorblock%]
echo 2. Download Subtitles     [%embed_subs%]
echo 3. Download Thumbnail     [%embed_thumb%]
echo 4. Add Metadata          [%embed_meta%]
echo 5. Use aria2c            [%use_aria2c%]
echo.

:quality_menu
cls
echo ╔══════════════════════════════════════════════════╗
echo ║              Quality Selection                    ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo Video Quality:
echo 1. Maximum Quality  │ Best video + audio
echo 2. 4K (2160p)      │ Ultra HD
echo 3. 1080p60         │ Full HD with 60fps
echo 4. 1080p           │ Full HD
echo 5. 720p60          │ HD with 60fps
echo 6. 720p            │ HD
echo.
echo Note: Higher quality needs more bandwidth
echo      60fps options need more processing power

