@echo off
REM Get absolute path to base directory
pushd "%~dp0.."
set "BASE_DIR=%CD%"
popd
set "download_dir=%BASE_DIR%\downloads"
set "TEMP_DIR=%download_dir%\.temp"
set "CACHE_DIR=%download_dir%\.cache"
set "LOG_DIR=%download_dir%\.logs"

REM Configure output templates with subdirectories
set "video_template=videos\%%(title).80s\%%(title)s.%%(ext)s"
set "playlist_template=playlists\%%(playlist_title).80s\%%(playlist_index)02d - %%(title)s.%%(ext)s"
set "channel_template=channels\%%(uploader).80s\%%(upload_date)s - %%(title)s.%%(ext)s"
set "audio_template=audio\%%(title).80s\%%(title)s.%%(ext)s"
set "live_template=live\%%(uploader).80s\%%(upload_date)s_%%(title).80s [LIVE].%%(ext)s"

REM Set output paths with full download directory
set "VIDEO_OUT=%download_dir%\%video_template%"
set "PLAYLIST_OUT=%download_dir%\%playlist_template%"
set "CHANNEL_OUT=%download_dir%\%channel_template%"
set "AUDIO_OUT=%download_dir%\%audio_template%"
set "LIVE_OUT=%download_dir%\%live_template%"

REM Create base directory structure silently
md "%download_dir%" 2>nul
md "%download_dir%\videos" 2>nul
md "%download_dir%\playlists" 2>nul
md "%download_dir%\channels" 2>nul
md "%download_dir%\audio" 2>nul
md "%download_dir%\live" 2>nul
md "%TEMP_DIR%" 2>nul
md "%CACHE_DIR%" 2>nul
md "%LOG_DIR%" 2>nul

REM Set instance-specific paths
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do set datetime=%%I
if not defined datetime set "datetime=00000000000000"
set "instance_id=%datetime:~0,14%_%RANDOM%"
set "instance_temp=%TEMP_DIR%\%instance_id%"
set "instance_log=%LOG_DIR%\%instance_id%.log"
md "%instance_temp%" 2>nul

REM Define download base path
set "download_base=%download_dir%"
