@echo off
Rem Make script folder the current folder
pushd %~dp0
Rem Save copy of Env variables
setlocal

Rem Generate LOG filename
for /f "tokens=1-4 delims=/ " %%d in ("%DATE%") do set ISO_DATE=%%g-%%e-%%f
for /f "tokens=1-4 delims=:." %%t in ("%TIME%") do set ISO_TIME=%%t.%%u.%%v

set LOG_FILE=%CD%\%COMPUTERNAME%_%~n0_%ISO_DATE%_%ISO_TIME%.log
set APPSIGHT_BIN=%ProgramFiles%\BMC Software\BMC AppSight\AppSight for Windows\Bin

if not exist "%APPSIGHT_BIN%" goto Not_Installed

rem Show old and new with dates and sizes
for %%F IN ("%APPSIGHT_BIN%\DnInfo.nef" ) do @echo Old File: %%~tF %%~zF %%~nxF %%~dpF >> "%LOG_FILE%"
for %%F IN ("DnInfo.nef" )                do @echo New File: %%~tF %%~zF %%~nxF %%~dpF >> "%LOG_FILE%"

set COPY_CMD=xcopy DnInfo.nef "%APPSIGHT_BIN%\*.*" /R /Y
@echo. >> "%LOG_FILE%"
@echo %COPY_CMD% >> "%LOG_FILE%"
rem Errors are written log
%COPY_CMD%  2>> "%LOG_FILE%"
if errorlevel 1 goto Copy_Error

@echo. >> "%LOG_FILE%"
@echo SUCCESS -- DnInfo.nef updated in "%APPSIGHT_BIN%" >> "%LOG_FILE%"
goto Done

:Not_Installed
@echo. >> "%LOG_FILE%"
@echo *** ERROR *** AppSight Bin folder was not found : "%APPSIGHT_BIN%" >> "%LOG_FILE%"
start notepad "%LOG_FILE%"
goto Done

:Copy_Error
@echo. >> "%LOG_FILE%"
@echo *** ERROR *** Copy failed >> "%LOG_FILE%"
start notepad "%LOG_FILE%"
goto Done


:Done
endlocal
popd

