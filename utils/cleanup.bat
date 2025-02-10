@echo off
REM Cleanup temporary files and directories
if defined instance_temp rd /s /q "%instance_temp%" 2>nul

REM Clear variables
set "previous_operation="
set "error_code="
set "error_msg="
set "link="
set "quality="
set "format_selection="
set "quality_str="

exit /b 0
