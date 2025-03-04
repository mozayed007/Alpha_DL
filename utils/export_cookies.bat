@echo off
setlocal EnableDelayedExpansion

REM Set script directory as base path
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

title YouTube Downloader - Browser Cookie Helper

cls
echo ===================================================
echo        YouTube Browser Cookie Helper
echo ===================================================
echo.
echo This utility will help you configure yt-dlp to use cookies
echo directly from your installed browser to bypass YouTube's
echo "Sign in to confirm you're not a bot" message.
echo.
echo Choose your browser:
echo  1. Chrome
echo  2. Firefox 
echo  3. Edge
echo  4. Opera
echo  5. Chromium
echo  6. Brave
echo  7. Safari (requires manual cookie file)
echo  8. Return to main menu
echo.
set /p "browser=Select browser (1-8): "

if "%browser%"=="1" set "browser_name=chrome" && goto set_browser
if "%browser%"=="2" set "browser_name=firefox" && goto set_browser
if "%browser%"=="3" set "browser_name=edge" && goto set_browser
if "%browser%"=="4" set "browser_name=opera" && goto set_browser
if "%browser%"=="5" set "browser_name=chromium" && goto set_browser
if "%browser%"=="6" set "browser_name=brave" && goto set_browser
if "%browser%"=="7" goto safari
if "%browser%"=="8" exit /b 0

echo Invalid selection. Please try again.
timeout /t 2 >nul
exit /b 1

:set_browser
echo.
echo Setting yt-dlp to use cookies directly from %browser_name%...
echo.

REM Update settings to use the selected browser
set "use_cookies=true"
set "cookie_browser=%browser_name%"
set "cookie_browser_args=--cookies-from-browser %browser_name%"

REM Update the base args in settings.bat (this is done in modules\settings.bat)
echo The downloader will now use cookies directly from your %browser_name% browser.
echo Make sure you are logged into YouTube in your %browser_name% browser.
echo.
echo This should solve the "Sign in to confirm you're not a bot" error
echo and allow you to download playlists and videos smoothly.
echo.
pause
exit /b 0

:safari
echo.
echo Safari requires manual cookie export:
echo 1. Install the "Cookie-Editor" extension
echo 2. Visit YouTube and log in
echo 3. Click the extension icon while on YouTube
echo 4. Click "Export" and save the text as "%SCRIPT_DIR%\..\cookies.txt"
echo.
echo Once exported, cookies will be used automatically.
echo.
pause
exit /b 0