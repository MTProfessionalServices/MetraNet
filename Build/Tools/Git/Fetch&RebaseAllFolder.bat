@echo off
call FetchAllFolder.bat %1%

if NOT "%1%"=="skip_pause" (
@echo Press any key to start rebase
pause >nul
)

call RebaseAllFolder.bat %1%