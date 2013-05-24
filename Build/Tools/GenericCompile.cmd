@echo off

set PACKAGENAME=%1
set IS6DIR=%2
set COMMON_INST=%3
set OUTDIR=%5

set CONFIGTMP=DEBUG
IF %DEBUG%==0 set CONFIGTMP=RELEASE
set DEBUGTYPE="DEBUGTYPE=1"
IF %DEBUG%==0 set DEBUGTYPE="DEBUGTYPE=0"


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

set CURRENTBUILD=%4
if %4 EQU "" set CURRENTBUILD=Full


set INCLUDEIFX=%IS6DIR%\Script\Ifx\Include
set INCLUDEISRT=%IS6DIR%\Script\Isrt\Include
set LINKPATHS=-LibPath"%IS6DIR%\Script\Ifx\Lib" -LibPath"%IS6DIR%\Script\Isrt\Lib" 
set LIBRARIES="isrt.obl" "ifx.obl" 
set DEFINITIONS=
set SWITCHES=-w50 -e50 -v3 -gi /D%DEBUGTYPE%

set INSTALLPROJECT=%ROOTDIR%\install\%PACKAGENAME%\%PACKAGENAME%.ipr
set INCLUDESCRIPT=%ROOTDIR%\install\%PACKAGENAME%\Script Files
set RULFILES=%ROOTDIR%\install\%PACKAGENAME%\Script Files\setup.rul

rem ==================================================
rem Compile
rem ==================================================
echo "%COMPILER%" "%RULFILES%" -I"%INCLUDEIFX%" -I"%INCLUDEISRT%" -I"%INCLUDESCRIPT%" %LINKPATHS% %LIBRARIES% %DEFINITIONS% %SWITCHES% /o%OUTDIR%\setup.inx
"%COMPILER%" "%RULFILES%" -I"%INCLUDEIFX%" -I"%INCLUDEISRT%" -I"%INCLUDESCRIPT%" %LINKPATHS% %LIBRARIES% %DEFINITIONS% %SWITCHES% /o%OUTDIR%\setup.inx

if ERRORLEVEL 1 goto InstallShieldCompileError


:end