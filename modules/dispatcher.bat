@echo off
setlocal EnableDelayedExpansion

REM Load settings
call "%~dp0..\config\settings.bat"

REM Get the choice parameter
set "choice=%~1"
if "%choice%"=="" goto error

:process_choice
if "%choice%"=="1" (
    call "%~dp0video.bat" download_video
) else if "%choice%"=="2" (
    call "%~dp0playlist.bat" download_playlist
) else if "%choice%"=="3" (
    call "%~dp0channel.bat" download_channel
) else if "%choice%"=="4" (
    call "%~dp0audio.bat" download_audio
) else if "%choice%"=="5" (
    call "%~dp0live.bat" download_live
) else if "%choice%"=="6" (
    call "%~dp0video.bat" custom_format
) else if "%choice%"=="7" (
    call "%~dp0audio.bat" extract_audio
) else if "%choice%"=="8" (
    call "%~dp0video.bat" batch_download
) else if "%choice%"=="9" (
    call "%~dp0video.bat" show_info
) else if "%choice%"=="10" (
    call "%~dp0video.bat" list_formats
) else if "%choice%"=="11" (
    call "%~dp0video.bat" download_thumb
) else if "%choice%"=="12" (
    call "%~dp0video.bat" download_subs
) else if "%choice%"=="13" (
    call "%~dp0settings.bat" change_directory
) else if "%choice%"=="14" (
    call "%~dp0settings.bat" quality_settings
) else if "%choice%"=="15" (
    call "%~dp0settings.bat" toggle_features
) else if "%choice%"=="16" (
    call "%~dp0settings.bat" network_settings
) else if "%choice%"=="17" (
    call "%~dp0settings.bat" hw_accel_menu
) else if "%choice%"=="18" (
    call "%~dp0settings.bat" cookie_settings
) else if "%choice%"=="19" (
    call "%~dp0settings.bat" update_ytdlp
) else if "%choice%"=="20" (
    exit /b 0
) else (
    goto error
)
exit /b 0

:error
echo Invalid choice. Please try again.
timeout /t 2 >nul
exit /b 1
