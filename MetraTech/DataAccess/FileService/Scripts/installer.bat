@echo off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem  Simple app to install or uninstall the the service
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem


SET OP=%1
SET PROG=MetraTechDataExportService.exe

SET FIRSTPART=%WINDIR%"\Microsoft.NET\Framework\v"
SET SECONDPART="\InstallUtil.exe"

:dotnet_check
SET DOTNETVER=4.0.30319
  IF EXIST %FIRSTPART%%DOTNETVER%%SECONDPART% GOTO param_check
SET DOTNETVER=2.0.50727
  IF EXIST %FIRSTPART%%DOTNETVER%%SECONDPART% GOTO param_check
SET DOTNETVER=1.1.4322
  IF EXIST %FIRSTPART%%DOTNETVER%%SECONDPART% GOTO param_check
SET DOTNETVER=1.0.3705
  IF EXIST %FIRSTPART%%DOTNETVER%%SECONDPART% GOTO param_check
GOTO fail

:param_check
IF "%1"=="" GOTO param_error
IF "%1"=="I" GOTO install
IF "%1"=="U" GOTO uninstall
IF "%1"=="i" GOTO install
IF "%1"=="u" GOTO uninstall
GOTO param_error

:install
  ECHO Found .NET Framework version %DOTNETVER%
  ECHO Installing service %MTOUTDIR%\%VERSION%\bin\%PROG%
  ECHO "%FIRSTPART%%DOTNETVER%%SECONDPART% /I %MTOUTDIR%\%VERSION%\bin\%PROG%"
  %FIRSTPART%%DOTNETVER%%SECONDPART% /I %MTOUTDIR%\%VERSION%\bin\%PROG%
  GOTO end
:uninstall
  ECHO Found .NET Framework version %DOTNETVER%
  ECHO Uninstalling service %MTOUTDIR%\%VERSION%\bin\%PROG%
  %FIRSTPART%%DOTNETVER%%SECONDPART% /U %MTOUTDIR%\%VERSION%\bin\%PROG%
  GOTO end
:fail
  echo FAILURE -- Could not find .NET Framework install
:param_error
  echo USAGE: installer.bat [install type (I or U)]
:end
  ECHO DONE!!!
  Pause