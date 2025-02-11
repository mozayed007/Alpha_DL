@echo off
setlocal EnableDelayedExpansion

if "%~1"=="download_playlist" goto download_playlist
goto :eof

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
set /p "start=Enter start index (optional, press Enter to start from beginning): "
set /p "end=Enter end index (optional, press Enter for all): "

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

REM Set output template for playlists
set "output_template=%PLAYLIST_OUT%"

REM Display download information
echo.
echo [Download Information]
echo • Content Type: playlist
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: %output_template%
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Build playlist range argument
set "playlist_range="
if not "%start%"=="" set "playlist_range=--playlist-start %start%"
if not "%end%"=="" set "playlist_range=!playlist_range! --playlist-end %end%"

REM Get first video info to set initial download profile
for /f "tokens=1" %%a in ('yt-dlp.exe --print filesize "%link%" 2^>nul') do (
    if not "%%a"=="" if not "%%a"=="NA" call "%~dp0..\config\settings.bat" :set_aria2c_profile "%%a"
)

REM Add playlist-specific arguments
set "playlist_args=--yes-playlist --no-overwrites --ignore-errors --no-abort-on-error"

yt-dlp.exe %ytdlp_base_args% %playlist_args% -f "%format_selection%" -o "%output_template%" %metadata_opts% %playlist_range% %aria2c_args% %hw_accel_opts% "%link%" || (
    echo Download failed. Please check your internet connection and URL.
    call "%~dp0..\lib\error.bat" download_failed
    pause
    exit /b 1
)

echo Download completed successfully!
pause
exit /b 0
