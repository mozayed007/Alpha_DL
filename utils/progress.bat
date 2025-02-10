@echo off
set "content_type=%~1"
set "url=%~2"
set "quality=%~3"
set "output=%~4"

echo.
echo [Download Progress]
echo • Content Type: %content_type%
echo • URL: %url%
echo • Quality: %quality%
echo • Output: %output%
echo • Hardware Accel: %hw_accel_available%
echo.
echo Starting download...
echo Press Q to quit, P to pause
echo.

REM Log progress
echo [%date% %time%] Download Progress >> "%instance_log%"
echo Content Type: %content_type% >> "%instance_log%"
echo URL: %url% >> "%instance_log%"
echo Quality: %quality% >> "%instance_log%"
echo Output: %output% >> "%instance_log%"
echo Hardware Acceleration: %hw_accel_available% >> "%instance_log%"
echo ---------------------------------------- >> "%instance_log%"
