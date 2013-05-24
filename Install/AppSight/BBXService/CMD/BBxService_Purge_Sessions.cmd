@echo off
setlocal
SET RET_CODE=0
rem Make the script dir the current dir
pushd %~dp0

pushd Internal
Call LogCMD.cmd "Enter %~n0"
CSCRIPT //NoLogo ProcessBBxSessionFiles.vbs DELETE
SET RET_CODE=%ERRORLEVEL%
Call LogCMD.cmd "Exit  %~n0 RC=%RET_CODE%"
@echo.
@echo BBXService Purge Sessions returned %RET_CODE%
CSCRIPT //NoLogo SleepNSeconds.vbs 10
popd

popd
EXIT /b %RET_CODE%
