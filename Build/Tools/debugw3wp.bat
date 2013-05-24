@echo off
REM meters once to make sure a w3wp process is spun up
REM autosdk localhost r:\extensions\core\test\autoSDK\metratech.com\testservice.xml
start /b /d "%PROGRAMFILES%\Debugging Tools for Windows\" windbg.exe -g -Q -pn w3wp.exe