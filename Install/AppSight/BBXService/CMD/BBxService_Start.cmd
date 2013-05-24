@echo off
setlocal
SET RET_CODE=0
rem Make the script dir the current dir
pushd %~dp0

pushd Internal
Call BBxService_Start_Profile.cmd "MetraNet_WSO75_003.rpr"
SET RET_CODE=%ERRORLEVEL%
@echo.
@echo BBxService Start Script returned %RET_CODE%
CSCRIPT //NoLogo SleepNSeconds.vbs 5
popd

popd
EXIT /b %RET_CODE%
