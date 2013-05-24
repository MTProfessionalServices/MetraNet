@echo off
REM To call buildProjectNoDepend.bat from a project use the following syntax:
REM %ROOTDIR%\MetraTech\buildProjectNoDepend.bat $(ProjectFileName)

set BuildMode=Debug

if not '%2' == '' (set BuildMode=%2)

echo Building %1
Echo Configuration %BuildMode%
devenv %1 /build %BuildMode%
echo Done.