cls
REM Save error level before cls
set "last_error=%errorlevel%"

REM Clear previous error if menu is reached normally
if "%previous_operation%"=="" set "error_code="

REM Show error message if coming from an error
if defined error_code (
    echo.
    echo Last error: !error_msg! (Code: !error_code!)
    echo See log file: !instance_log!
    echo.
)

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

if "%choice%"=="" exit /b 1
if %choice% LSS 1 exit /b 1
if %choice% GTR 20 exit /b 1

if "%choice%"=="20" exit /b 1

REM Call dispatcher with the choice
call "%~dp0..\modules\dispatcher.bat" "%choice%"
exit /b %errorlevel%
