@echo off

set PACKAGENAME=%1
set PACKAGENAME=MetraTech_Billing_Platform
set IS6DIR=%2
set COMMON_INST=%3
set DEVINSTDIR=%ROOTDIR%\install\%PACKAGENAME%
set TMPTHRDPTY=%ROOTDIR%\ThirdParty
set CONFIGTMP=DEBUG
IF %DEBUG%==0 set CONFIGTMP=RELEASE
set DEBUGFLAG=DEBUGFLAG=1
IF %DEBUG%==0 set DEBUGFLAG=DEBUGFLAG=0


rem Hard Coded PackageName
rem Hard Coded IS6 Drive
rem Use VBScript harness and Registry interrogation instead.
rem 
set IS6DRIVE=C:
set IS6DIR=%IS6DRIVE%\Program Files\InstallShield\InstallShield Professional 6.1
if NOT exist "%IS6DIR%"  set IS6DIR=D:\Program Files\InstallShield\InstallShield Professional 6.1
if %COMPUTERNAME% == DARKOVER set IS6DIR=D:\Program Files\InstallShield\InstallShield Professional 6
set COMMON_INST=%IS6DRIVE%\Program Files\Common Files\InstallShield
if NOT exist "%COMMON_INST%"  set COMMON_INST=D:\Program Files\Common Files\InstallShield


@echo PARAMETERS PASSED IN
@echo PACKAGENAME = %PACKAGENAME%
@echo IS6DIR = %IS6DIR%
@echo COMMON_INST = %COMMON_INST%
@echo.

set COMPILER=%COMMON_INST%\IScript\Compile.exe
set BUILDER=%IS6DIR%\Program\isbuild.exe

rem ===============================================
rem Set the environment for the compiler
rem ===============================================

set CURRENTBUILD=Full
set INCLUDEIFX=%IS6DIR%\Script\Ifx\Include
set INCLUDEISRT=%IS6DIR%\Script\Isrt\Include
set LINKPATHS=-LibPath"%IS6DIR%\Script\Ifx\Lib" -LibPath"%IS6DIR%\Script\Isrt\Lib" 
set LIBRARIES="isrt.obl" "ifx.obl" 
set DEFINITIONS=
set SWITCHES=-w50 -e50 -v3 -gi /D%DEBUGFLAG%

set INSTALLPROJECT=%DEVINSTDIR%\MetraTech_Billing_Platform.ipr
set INCLUDESCRIPT=%DEVINSTDIR%\Script Files
set RULFILES=%DEVINSTDIR%\Script Files\setup.rul

rem ==================================================
rem Compile
rem ==================================================
echo "%COMPILER%" "%RULFILES%" -I"%INCLUDEIFX%" -I"%INCLUDEISRT%" -I"%INCLUDESCRIPT%" -I"%ROOTDIR%\include" %LINKPATHS% %LIBRARIES% %DEFINITIONS% %SWITCHES%
"%COMPILER%" "%RULFILES%" -I"%INCLUDEIFX%" -I"%INCLUDEISRT%" -I"%INCLUDESCRIPT%" -I"%ROOTDIR%\include" %LINKPATHS% %LIBRARIES% %DEFINITIONS% %SWITCHES%

if ERRORLEVEL 1 goto InstallShieldCompileError

rem ==================================================
rem build
rem ==================================================
echo "%BUILDER%" -p"%INSTALLPROJECT%" -m"%CURRENTBUILD%" -b"%MTOUTDIR%\install\%CONFIGTMP%\IS_Media\%PACKAGENAME%"
"%BUILDER%" -p"%INSTALLPROJECT%" -m"%CURRENTBUILD%" -b"%MTOUTDIR%\install\%CONFIGTMP%\IS_Media\%PACKAGENAME%"

mkdir "%MTOUTDIR%\install\%CONFIGTMP%\_CD\%PACKAGENAME%"
copy  "%MTOUTDIR%\install\%CONFIGTMP%\IS_Media\%PACKAGENAME%\Disk Images\Disk1\*.*"  "%OUTDIR%\install\%CONFIGTMP%\_CD\%PACKAGENAME%\*.*"


:end