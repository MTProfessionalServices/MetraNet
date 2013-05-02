@echo off

msbuild.exe MSBuild\LegacySmokeTest.proj /t:all /p:config=release /p:platform=x86