@echo off
Rem Make script folder the current folder
pushd %~dp0

Rem Save copy of Env variables
setlocal
Rem Generate LOG filename
for /f "tokens=1-4 delims=/ " %%d in ("%DATE%") do set ISO_DATE=%%g-%%e-%%f
for /f "tokens=1-4 delims=:." %%t in ("%TIME%") do set ISO_TIME=%%t.%%u.%%v

set LOG_FILE=%CD%\%COMPUTERNAME%_BBXService_Install_%ISO_DATE%_%ISO_TIME%.log

Title AppSight Black Box Service Silent Install
@echo About to install AppSight Black Box Service ...
@pause
@echo Installing AppSight Black Box Service ...

"Embedded Windows Black Box Service.exe" /s /f1"%CD%\ServiceBlackBox_Install.iss" /f2"%LOG_FILE%"
start notepad "%LOG_FILE%"

call DnInfo_Update.cmd

endlocal
popd
