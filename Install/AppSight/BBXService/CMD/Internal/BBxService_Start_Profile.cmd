@echo off
setlocal
PATH %SystemRoot%\System32;%PATH%
SET RET_CODE=0
SET ERR_MSG=
rem Make the script dir the current dir
pushd %~dp0

call LogCMD.cmd "Enter %~n0" "%~1"

:CheckFileSpecified
if not [%1]==[] goto CheckFileExists
SET ERR_MSG=RPR File Not Specied
goto ErrorExit

:CheckFileExists
pushd ..\..\RPR
SET RPR_FILE=%CD%\%~1
popd
if exist "%RPR_FILE%" goto VerifyStopped
SET ERR_MSG=RPR File Does Not Exist : "%RPR_FILE%"
goto ErrorExit

:VerifyStopped
sc query BBxService | FIND "STOPPED" > nul
SET RET_CODE=%ERRORLEVEL%
if %RET_CODE%==0 goto StartBlackBox
SET ERR_MSG=BBxService not in a STOPPED state
goto ErrorExit

:StartBlackBox
Rem Generate ASL filename
for /f "tokens=1-4 delims=/ " %%d in ("%DATE%") do set ISO_DATE=%%g-%%e-%%f
for /f "tokens=1-4 delims=:." %%t in ("%TIME%") do set ISO_TIME=%%t.%%u.%%v
pushd ..\..\ASL
for /f %%f in ("%RPR_FILE%") do set ASL_FILE=%CD%\%COMPUTERNAME%_%%~nf_%ISO_DATE%_%ISO_TIME%.asl
popd

Rem Make sure in stand-alone mode
reg add "HKLM\SOFTWARE\Identify\AppSight Black Box Service\Common" /v WorkWithServer /t REG_DWORD /d 0 /f > nul

Rem Start the BBXService with appropriate parameters
@echo "%RPR_FILE%" > Last_RPR.txt
@echo "%ASL_FILE%" > Last_ASL.txt
SET START_CMD=SC START BBxService /rpr "%RPR_FILE%" /asl "%ASL_FILE%"
call LogCMD.cmd "***** %~n0" %START_CMD%
@echo %START_CMD%
%START_CMD% | Find " STATE "
SET RET_CODE=%ERRORLEVEL%
goto AllExit

:ErrorExit
SET RET_CODE=1
@echo [ERROR] %ERR_MSG%
goto AllExit

:AllExit
call LogCMD.cmd "Exit  %~n0 RC=%RET_CODE%" "%ERR_MSG%"
@popd
EXIT /B %RET_CODE%







