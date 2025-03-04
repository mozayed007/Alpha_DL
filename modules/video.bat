@echo off
setlocal EnableDelayedExpansion

if "%~1"=="download_video" goto download_video
if "%~1"=="custom_format" goto custom_format
if "%~1"=="batch_download" goto batch_download
if "%~1"=="show_info" goto show_info
if "%~1"=="list_formats" goto list_formats
if "%~1"=="download_thumb" goto download_thumb
if "%~1"=="download_subs" goto download_subs
goto :eof

:download_video
cls
echo ===================================================
echo              Download Video
echo ===================================================
echo.
echo Select Quality:
echo  1. Best Quality   (max resolution + best audio)
echo  2. 1080p         (FHD)
echo  3. 720p          (HD)
echo.
set /p "quality=Select quality (1-3): "

if not "%quality%"=="1" if not "%quality%"=="2" if not "%quality%"=="3" (
    echo Invalid quality selection. Please choose 1, 2, or 3.
    pause
    call "%~dp0..\lib\return_to_menu.bat"
    exit /b
)

set /p "link=Enter video URL: "
if "%link%"=="" (
    echo URL cannot be empty.
    pause
    call "%~dp0..\lib\return_to_menu.bat"
    exit /b
)

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

REM Set output template for videos
set "output_template=%DOWNLOAD_DIR%\videos\%%(title)s.%%(ext)s"

if not exist "%DOWNLOAD_DIR%\videos" mkdir "%DOWNLOAD_DIR%\videos"

REM Display download information
echo.
echo [Download Information]
echo • Content Type: video
echo • URL: %link%
echo • Quality: %quality_str%
echo • Output: %output_template%
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...

REM Get video info and set appropriate download profile
for /f "tokens=1" %%a in ('yt-dlp.exe --print filesize "%link%" 2^>nul') do (
    if not "%%a"=="" if not "%%a"=="NA" call "%~dp0..\config\settings.bat" :set_aria2c_profile "%%a"
)

REM Set post-processing arguments
set "post_process_args=--merge-output-format mkv --remux-video mkv --embed-chapters"

yt-dlp.exe %ytdlp_base_args% --format "%format_selection%" --output "%output_template%" %metadata_opts% %aria2c_args% --no-part %hw_accel_opts% %post_process_args% "%link%" || (
    echo Download failed. Please check your internet connection and URL.
    call "%~dp0..\lib\error.bat" download_failed
    pause
    call "%~dp0..\lib\return_to_menu.bat"
    exit /b
)

echo Download completed successfully!
pause
call "%~dp0..\lib\return_to_menu.bat"
exit /b

:custom_format
cls
echo ===================================================
echo              Custom Format Download
echo ===================================================
echo.
set /p "link=Enter video URL: "
echo.
echo Getting available formats...
yt-dlp.exe -F "%link%"
echo.
set /p "format=Enter format code: "

REM Set output template for videos
set "output_template=%DOWNLOAD_DIR%\videos\%%(title)s.%%(ext)s"

echo.
echo Starting download...

REM Get video info and set appropriate download profile
for /f "tokens=1" %%a in ('yt-dlp.exe --print filesize "%link%" 2^>nul') do (
    if not "%%a"=="" if not "%%a"=="NA" call "%~dp0..\config\settings.bat" :set_aria2c_profile "%%a"
)

REM Set post-processing arguments
set "post_process_args=--merge-output-format mkv --remux-video mkv --embed-chapters"

yt-dlp.exe %ytdlp_base_args% -f "%format%" -o "%output_template%" %metadata_opts% %aria2c_args% --no-part %hw_accel_opts% %post_process_args% "%link%" || (
    set "error_code=%errorlevel%"
    echo Error occurred with code: !error_code!
    pause
    call "%~dp0..\lib\error.bat" handle_error
    call "%~dp0..\lib\return_to_menu.bat"
    exit /b
)

echo.
echo Download complete!
pause
call "%~dp0..\lib\return_to_menu.bat"
exit /b

:batch_download
cls
echo ===================================================
echo              Batch Download
echo ===================================================
echo.
echo Enter URLs (one per line, press Ctrl+Z and Enter when done):
echo.
type con > "%TEMP_DIR%\batch_urls.txt"

echo.
echo Select Quality:
echo  1. Best Quality   (max resolution + best audio)
echo  2. 1080p         (FHD)
echo  3. 720p          (HD)
echo.
set /p "quality=Select quality (1-3): "

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

REM Set output template for videos
set "output_template=%DOWNLOAD_DIR%\videos\%%(title)s.%%(ext)s"

echo.
echo Starting batch download...
echo Press Q to quit, P to pause
echo.

REM Set post-processing arguments
set "post_process_args=--merge-output-format mkv --remux-video mkv --embed-chapters"

yt-dlp.exe %ytdlp_base_args% -f "%format_selection%" -o "%output_template%" %metadata_opts% %aria2c_args% --no-part %hw_accel_opts% %post_process_args% -a "%TEMP_DIR%\batch_urls.txt" || (
    set "error_code=%errorlevel%"
    echo Error occurred with code: !error_code!
    pause
    call "%~dp0..\lib\error.bat" handle_error
    call "%~dp0..\lib\return_to_menu.bat"
    exit /b
)

del "%TEMP_DIR%\batch_urls.txt" 2>nul
echo.
echo Batch download complete!
pause
call "%~dp0..\lib\return_to_menu.bat"
exit /b

:show_info
cls
echo ===================================================
echo              Show Video Information
echo ===================================================
echo.
set /p "link=Enter video URL: "
echo.
echo Getting video information...
echo.
yt-dlp.exe --dump-json "%link%" | python -m json.tool
echo.
pause
call "%~dp0..\lib\return_to_menu.bat"
exit /b

:list_formats
cls
echo ===================================================
echo              List Available Formats
echo ===================================================
echo.
set /p "link=Enter video URL: "
echo.
echo Getting available formats...
echo.
yt-dlp.exe -F "%link%"
echo.
pause
call "%~dp0..\lib\return_to_menu.bat"
exit /b

:download_thumb
cls
echo ===================================================
echo              Download Thumbnail
echo ===================================================
echo.
set /p "link=Enter video URL: "
echo.
echo Downloading thumbnail...
yt-dlp.exe %ytdlp_base_args% --write-thumbnail --skip-download -o "%DOWNLOAD_DIR%\thumbnails\%%(title)s.%%(ext)s" %aria2c_args% "%link%" || (
    set "error_code=%errorlevel%"
    echo Error occurred with code: !error_code!
    pause
    call "%~dp0..\lib\error.bat" handle_error
    call "%~dp0..\lib\return_to_menu.bat"
    exit /b
)
echo.
echo Thumbnail downloaded!
pause
call "%~dp0..\lib\return_to_menu.bat"
exit /b

:download_subs
cls
echo ===================================================
echo              Download Subtitles
echo ===================================================
echo.
set /p "link=Enter video URL: "
echo.
echo Available subtitle languages:
yt-dlp.exe --list-subs "%link%"
echo.
set /p "lang=Enter language code (e.g., en, es, fr): "
echo.
echo Downloading subtitles...
yt-dlp.exe %ytdlp_base_args% --write-subs --write-auto-subs --skip-download -o "%DOWNLOAD_DIR%\subtitles\%%(title)s.%%(ext)s" %aria2c_args% "%link%" || (
    set "error_code=%errorlevel%"
    echo Error occurred with code: !error_code!
    pause
    call "%~dp0..\lib\error.bat" handle_error
    call "%~dp0..\lib\return_to_menu.bat"
    exit /b
)
echo.
echo Subtitles downloaded!
pause
call "%~dp0..\lib\return_to_menu.bat"
exit /b
