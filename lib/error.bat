@echo off
setlocal EnableDelayedExpansion

if "%~1"=="handle_error" goto handle_error
goto :eof

:handle_error
echo.
echo ===================================================
echo                   Error Details
echo ===================================================
echo Error Code: %error_code%
echo.
if "%error_code%"=="1" (
    echo General error occurred during download
    echo Possible causes:
    echo - Invalid URL
    echo - Network connection issues
    echo - Content unavailable or private
)
if "%error_code%"=="2" (
    echo Invalid command line options or parameters
)
if "%error_code%"=="100" (
    echo Private or unavailable content
)
if "%error_code%"=="101" (
    echo Network error occurred
)
if "%error_code%"=="102" (
    echo Unable to extract video information
)
echo.
echo Press any key to continue...
pause >nul
exit /b %error_code%

REM Log error details with timestamp
echo ---------------------------------------- >> "%instance_log%"
echo Error: !error_msg! (Code: %error_code%) >> "%instance_log%"
echo Time: %date% %time% >> "%instance_log%"
echo Command: %cmdline% >> "%instance_log%"
echo Previous Operation: %previous_operation% >> "%instance_log%"
echo ---------------------------------------- >> "%instance_log%"

if "%error_code%"=="%ERROR_ARIA2C%" (
    echo.
    echo aria2c encountered an error
    echo Retrying download without aria2c...
    endlocal & (
        set "use_aria2c=false"
        set "aria2c_args="
        goto :retry_download
    )
)

if "%hw_accel_available%"=="true" (
    echo.
    echo Hardware acceleration was enabled
    echo Retrying without hardware acceleration...
    endlocal & (
        set "hw_accel_available=false"
        set "ffmpeg_args="
        goto :retry_download
    )
)

choice /c RMQ /n /m "Retry (R), Return to Menu (M), or Quit (Q)? "
if errorlevel 3 goto :cleanup
if errorlevel 2 exit /b 0
if errorlevel 1 goto :retry_download

:retry_download
echo.
echo Retrying download with modified settings...
echo [%date% %time%] Retrying download >> "%instance_log%"
endlocal & (
    call "%~dp0..\modules\dispatcher.bat" %choice%
)
exit /b 0

:cleanup
rd /s /q "%instance_temp%" 2>nul
exit /b %error_code%
