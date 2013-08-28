@echo off

msbuild.exe MSBuild\LegacySmokeTest_Debug.proj /t:all /p:config=debug /p:platform=x86
pause