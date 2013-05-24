@echo off
setlocal
SET RET_CODE=0
rem Make the script dir the current dir
pushd %~dp0

pushd Internal
Call LogCMD.cmd "Enter %~n0"
CSCRIPT //NoLogo StopBBxService.vbs
SET RET_CODE=%ERRORLEVEL%
Call LogCMD.cmd "Exit  %~n0 RC=%RET_CODE%"
@echo.
@echo BBxService Stop returned %RET_CODE%
CSCRIPT //NoLogo SleepNSeconds.vbs 5
popd

popd
EXIT /b %RET_CODE%
