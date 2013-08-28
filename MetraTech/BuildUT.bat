@echo off

msbuild.exe MSBuild\UnitTest.proj /t:all /p:config=%VERSION% /p:platform=x86

pause