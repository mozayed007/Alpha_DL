@echo off
setlocal EnableDelayedExpansion

if "%~1"=="download_audio" goto download_audio
goto :eof

:download_audio
cls
echo ===================================================
echo              Download Audio
echo ===================================================
echo.
echo Select Audio Format:
echo  1. MP3
echo  2. M4A
echo  3. WAV
echo  4. OPUS
echo.
set /p "format=Select format (1-4): "
set /p "link=Enter URL: "

REM Set format based on selection
if "%format%"=="1" (
    set "audio_format=mp3"
    set "format_str=MP3"
)
if "%format%"=="2" (
    set "audio_format=m4a"
    set "format_str=M4A"
)
if "%format%"=="3" (
    set "audio_format=wav"
    set "format_str=WAV"
)
if "%format%"=="4" (
    set "audio_format=opus"
    set "format_str=OPUS"
)

REM Set output template for audio
set "output_template=%DOWNLOAD_DIR%\audio\%%(title)s.%%(ext)s"

REM Display download information
echo.
echo [Download Information]
echo • Content Type: audio
echo • URL: %link%
echo • Format: %format_str%
echo • Output: %output_template%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Get audio info and set appropriate download profile
for /f "tokens=1" %%a in ('yt-dlp.exe --print filesize "%link%" 2^>nul') do (
    if not "%%a"=="" if not "%%a"=="NA" call "%~dp0..\config\settings.bat" :set_aria2c_profile "%%a"
)

REM Download with all features enabled
yt-dlp.exe %ytdlp_base_args% -f "bestaudio" -x --audio-format %audio_format% --audio-quality 0 --embed-metadata --embed-thumbnail -o "%output_template%" %aria2c_args% %hw_accel_opts% "%link%" || (
    echo Download failed. Please check your internet connection and URL.
    call "%~dp0..\lib\error.bat" download_failed
    pause
    exit /b 1
)

echo Download completed successfully!
pause
exit /b 0
