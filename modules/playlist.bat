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
    set "format_selection=bestvideo[protocol!=http_dash_segments][protocol!=m3u8]*+bestaudio/best"
    set "quality_str=Best Quality"
)
if "%quality%"=="2" (
    set "format_selection=bestvideo[height<=1080][protocol!=http_dash_segments][protocol!=m3u8]+bestaudio/best[height<=1080]"
    set "quality_str=1080p"
)
if "%quality%"=="3" (
    set "format_selection=bestvideo[height<=720][protocol!=http_dash_segments][protocol!=m3u8]+bestaudio/best[height<=720]"
    set "quality_str=720p"
)

REM Set metadata embedding options
set "metadata_opts=--write-thumbnail --embed-thumbnail --write-subs --write-auto-subs --embed-subs --embed-metadata --convert-thumbnails jpg"

REM Set output template for playlists
set "output_template=%PLAYLIST_OUT%"

REM Check if cookies exist and prompt if not
set "cookies_file=%~dp0..\cookies.txt"
if not exist "!cookies_file!" (
    echo.
    echo WARNING: No cookies.txt file found. YouTube will likely block your download.
    echo Would you like to export cookies from your browser first?
    choice /c YN /n /m "(Y)es or (N)o? "
    if errorlevel 1 if not errorlevel 2 (
        call "%~dp0..\utils\export_cookies.bat"
        if not exist "!cookies_file!" (
            echo.
            echo No cookies file created. Download may fail.
            echo.
            choice /c YN /n /m "Do you want to continue anyway? (Y)es or (N)o: "
            if errorlevel 2 (
                call "%~dp0..\lib\return_to_menu.bat"
                exit /b
            )
        )
    )
)

REM Set up force cookie arguments regardless of settings
set "cookie_args="
if exist "!cookies_file!" (
    set "cookie_args=--cookies !cookies_file!"
    echo Cookie file found and will be used for authentication.
)

REM Display download information
echo.
echo [Download Information]
echo • Content Type: playlist
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: %output_template%
echo • Hardware Accel: %hw_accel_available%
echo • Using Cookies: %use_cookies%
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

REM Set post-processing arguments for after download
set "post_process_args=--merge-output-format mkv --remux-video mkv --embed-chapters"

REM Add additional arguments to handle YouTube rate limiting and anti-bot measures
set "youtube_args=--extractor-retries 5 --skip-unavailable-fragments --fragment-retries 10 --retry-sleep 5"

REM YouTube player args to bypass signature decryption issue
set "player_args=--extractor-args youtube:player_client=web"

yt-dlp.exe %ytdlp_base_args% %playlist_args% %cookie_args% %youtube_args% %player_args% -f "%format_selection%" -o "%output_template%" %metadata_opts% %aria2c_args% --no-part %hw_accel_opts% %post_process_args% %playlist_range% "%link%" || (
    echo Download failed. Please check your internet connection and URL.
    echo.
    echo Common solutions:
    echo 1. Export cookies from your browser using menu option 18
    echo 2. Check your internet connection
    echo 3. Try again later (YouTube may be temporarily blocking downloads)
    echo.
    call "%~dp0..\lib\error.bat" download_failed
    pause
    call "%~dp0..\lib\return_to_menu.bat"
    exit /b
)

echo Download completed successfully!
pause
call "%~dp0..\lib\return_to_menu.bat"
exit /b
