@echo off

msbuild.exe MSBuild\LegacySmokeTest.proj /t:all /p:config=%VERSION% /p:platform=x86

pause