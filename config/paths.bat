@echo off
REM Set up directory structure
set "BASE_DIR=%~dp0.."
set "download_dir=%BASE_DIR%\downloads"
set "TEMP_DIR=%download_dir%\.temp"
set "CACHE_DIR=%download_dir%\.cache"
set "LOG_DIR=%download_dir%\.logs"

REM Configure output templates
set "video_template=%%(title)s%%(title)s.%%(ext)s"
set "playlist_template=%%(playlist_title)s%%(playlist_title)s - %%(playlist_index)02d - %%(title)s.%%(ext)s"
set "channel_template=%%(uploader)s%%(uploader)s - %%(upload_date)s - %%(title)s.%%(ext)s"
set "audio_template=%%(title).80s.%%(ext)s"
set "live_template=%%(uploader)s\%%(upload_date)s_%%(title).80s [LIVE].%%(ext)s"

REM Set output paths
set "VIDEO_OUT=%download_dir%\videos\%video_template%"
set "PLAYLIST_OUT=%download_dir%\playlists\%playlist_template%"
set "CHANNEL_OUT=%download_dir%\channels\%channel_template%"
set "AUDIO_OUT=%download_dir%\audio\%audio_template%"
set "LIVE_OUT=%download_dir%\live\%live_template%"

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

REM Set instance-specific paths
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do set datetime=%%I
if not defined datetime set "datetime=00000000000000"
set "instance_id=%datetime:~0,14%_%RANDOM%"
set "instance_temp=%TEMP_DIR%\%instance_id%"
set "instance_log=%LOG_DIR%\%instance_id%.log"
md "%instance_temp%" 2>nul
