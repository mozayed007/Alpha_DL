@echo off
REM Initialize modules
if /I "%module_enabled%"=="true" (
    echo Initializing modules...
    REM ...module initialization code...
) else (
    echo Modules disabled.
)
exit /b 0
