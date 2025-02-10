@echo off
setlocal EnableDelayedExpansion

if "%~1"=="change_directory" goto change_directory
if "%~1"=="quality_settings" goto quality_settings
if "%~1"=="toggle_features" goto toggle_features
if "%~1"=="network_settings" goto network_settings
if "%~1"=="hw_accel_menu" goto hw_accel_menu
if "%~1"=="cookie_settings" goto cookie_settings
if "%~1"=="update_ytdlp" goto update_ytdlp
goto :eof

:change_directory
cls
echo ===================================================
echo              Change Download Directory
echo ===================================================
echo.
echo Current directory: %DOWNLOAD_DIR%
echo.
set /p "new_dir=Enter new download directory (or press Enter to keep current): "
if not "%new_dir%"=="" (
    md "%new_dir%" 2>nul
    md "%new_dir%\videos" 2>nul
    md "%new_dir%\playlists" 2>nul
    md "%new_dir%\channels" 2>nul
    md "%new_dir%\audio" 2>nul
    md "%new_dir%\live" 2>nul
    md "%new_dir%\.temp" 2>nul
    md "%new_dir%\.cache" 2>nul
    md "%new_dir%\.logs" 2>nul
    set "DOWNLOAD_DIR=%new_dir%"
    echo.
    echo Download directory updated!
)
pause
exit /b 0

:quality_settings
cls
echo ===================================================
echo              Quality Settings
echo ===================================================
echo.
echo Current quality: %quality_str%
echo.
echo Select Default Quality:
echo  1. Best Quality   (max resolution + best audio)
echo  2. 1080p         (FHD)
echo  3. 720p          (HD)
echo.
set /p "quality=Select quality (1-3): "

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
echo Quality settings updated!
pause
exit /b 0

:toggle_features
cls
echo ===================================================
echo              Toggle Features
echo ===================================================
echo.
echo Current settings:
echo 1. SponsorBlock: %use_sponsorblock%
echo 2. Aria2c: %use_aria2c%
echo 3. Subtitles: %embed_subs%
echo 4. Thumbnails: %embed_thumb%
echo 5. Metadata: %embed_meta%
echo.
set /p "feature=Select feature to toggle (1-5): "

if "%feature%"=="1" (
    if "%use_sponsorblock%"=="true" (set "use_sponsorblock=false") else (set "use_sponsorblock=true")
)
if "%feature%"=="2" (
    if "%use_aria2c%"=="true" (set "use_aria2c=false") else (set "use_aria2c=true")
)
if "%feature%"=="3" (
    if "%embed_subs%"=="true" (set "embed_subs=false") else (set "embed_subs=true")
)
if "%feature%"=="4" (
    if "%embed_thumb%"=="true" (set "embed_thumb=false") else (set "embed_thumb=true")
)
if "%feature%"=="5" (
    if "%embed_meta%"=="true" (set "embed_meta=false") else (set "embed_meta=true")
)
echo.
echo Features updated!
pause
exit /b 0

:network_settings
cls
echo ===================================================
echo              Network Settings
echo ===================================================
echo.
echo 1. Configure Proxy
echo 2. Set Download Speed Limit
echo 3. Configure Retries
echo.
set /p "option=Select option (1-3): "

if "%option%"=="1" (
    set /p "proxy=Enter proxy URL (or press Enter to disable): "
    if not "%proxy%"=="" (
        set "proxy_args=--proxy %proxy%"
    ) else (
        set "proxy_args="
    )
)
if "%option%"=="2" (
    set /p "speed=Enter download speed limit in MB/s (0 for unlimited): "
    if not "%speed%"=="0" (
        set "aria2c_args=!aria2c_args! --max-overall-download-limit=%speed%M"
    )
)
if "%option%"=="3" (
    set /p "retries=Enter number of retries (default is 10): "
    set "retry_args=--retries %retries% --fragment-retries %retries%"
)
echo.
echo Network settings updated!
pause
exit /b 0

:hw_accel_menu
cls
echo ===================================================
echo              Hardware Acceleration
echo ===================================================
echo.
echo Current status: %hw_accel_available% (%hw_accel%)
echo.
echo 1. Enable Hardware Acceleration
echo 2. Disable Hardware Acceleration
echo 3. Select Device
echo.
set /p "option=Select option (1-3): "

if "%option%"=="1" (
    set "hw_accel_available=true"
    echo Select acceleration type:
    echo 1. NVIDIA (CUDA)
    echo 2. Intel (QSV)
    echo 3. AMD (AMF)
    set /p "accel_type=Select type (1-3): "
    if "%accel_type%"=="1" set "hw_accel=cuda"
    if "%accel_type%"=="2" set "hw_accel=qsv"
    if "%accel_type%"=="3" set "hw_accel=amf"
)
if "%option%"=="2" (
    set "hw_accel_available=false"
    set "hw_accel="
    set "hw_accel_device="
)
if "%option%"=="3" (
    set /p "device=Enter device number (0-9): "
    set "hw_accel_device=%device%"
)
echo.
echo Hardware acceleration settings updated!
pause
exit /b 0

:cookie_settings
cls
echo ===================================================
echo              Cookie Settings
echo ===================================================
echo.
echo 1. Import cookies from browser
echo 2. Load cookies from file
echo 3. Clear cookies
echo.
set /p "option=Select option (1-3): "

if "%option%"=="1" (
    echo Select browser:
    echo 1. Chrome
    echo 2. Firefox
    echo 3. Edge
    set /p "browser=Select browser (1-3): "
    if "%browser%"=="1" yt-dlp.exe --cookies-from-browser chrome
    if "%browser%"=="2" yt-dlp.exe --cookies-from-browser firefox
    if "%browser%"=="3" yt-dlp.exe --cookies-from-browser edge
)
if "%option%"=="2" (
    set /p "cookie_file=Enter path to cookie file: "
    copy "%cookie_file%" "%TEMP_DIR%\cookies.txt" >nul
)
if "%option%"=="3" (
    del "%TEMP_DIR%\cookies.txt" 2>nul
)
echo.
echo Cookie settings updated!
pause
exit /b 0

:update_ytdlp
cls
echo ===================================================
echo              Update yt-dlp
echo ===================================================
echo.
echo Checking for updates...
yt-dlp.exe -U
echo.
pause
exit /b 0
