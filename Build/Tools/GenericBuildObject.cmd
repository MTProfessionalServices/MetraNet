@echo off

set PACKAGENAME=%1
set IS6DIR=%2
set COMMON_INST=%3

@echo PARAMETERS PASSED IN
@echo PACKAGENAME = %PACKAGENAME%
@echo IS6DIR = %IS6DIR%
@echo COMMON_INST = %COMMON_INST%
@echo.

set CONFIGTMP=DEBUG
IF %DEBUG%==0 set CONFIGTMP=RELEASE
set COMPILER=%COMMON_INST%\IScript\Compile.exe
set BUILDER=%IS6DIR%\Program\isbuild.exe

rem ===============================================
rem Set the environment for the compiler
rem ===============================================

set CURRENTBUILD=default
set INCLUDEIFX=%IS6DIR%\Script\Ifx\Include
set INCLUDEISRT=%IS6DIR%\Script\Isrt\Include
set LINKPATHS=-LibPath"%IS6DIR%\Script\Ifx\Lib" -LibPath"%IS6DIR%\Script\Isrt\Lib" 
set LIBRARIES="isrt.obl" "ifxobject.obl"
set DEFINITIONS=-DIFX_OBJECTS
set SWITCHES=-w50 -e50 -v3 -gi

set INSTALLPROJECT=%ROOTDIR%\install\%PACKAGENAME%\%PACKAGENAME%.ipr
set INCLUDESCRIPT=%ROOTDIR%\install\%PACKAGENAME%\Script Files
set RULFILES=%ROOTDIR%\install\%PACKAGENAME%\Script Files\setup.rul

rem ==================================================
rem Compile
rem ==================================================
"%COMPILER%" "%RULFILES%" -I"%INCLUDEIFX%" -I"%INCLUDEISRT%" -I"%INCLUDESCRIPT%" %LINKPATHS% %LIBRARIES% %DEFINITIONS% %SWITCHES%

if ERRORLEVEL 1 goto InstallShieldCompileError

rem ==================================================
rem build
rem ==================================================
@echo "%BUILDER%" -r -p"%INSTALLPROJECT%" -m"%CURRENTBUILD%" -b"%MTOUTDIR%\install\%CONFIGTMP%\IS_Media\%PACKAGENAME%
"%BUILDER%" -r -p"%INSTALLPROJECT%" -m"%CURRENTBUILD%" -b"%MTOUTDIR%\install\%CONFIGTMP%\IS_Media\%PACKAGENAME%

:end