@echo OFF
@echo ***  Upgarde script for MetraNet 8.1.0  ***
@echo #1. Adds files to '%MTRMP%' RMP folder
@echo #2. Remobes unnecessary files
@echo #3. Runs script to Upgrade DB according to specified DB type
@echo.
SET WorkDir=%~dp0

pushd %WorkDir%
:ASKUSER
SET DB_TYPE=%1%
IF "none%DB_TYPE%"=="none" SET /P DB_TYPE="Specify 'MSSQL' or 'Oracle' upgrade: "

echo DB upgrade is '%DB_TYPE%'

SET ISSETDBTYPE=false
SET FOLDERFORADD=AddFiles
SET SCRIPTS=CommonScripts

IF /I "%DB_TYPE%"=="mssql" SET ISSETDBTYPE=true
IF /I "%DB_TYPE%"=="oracle" SET ISSETDBTYPE=true

IF "%ISSETDBTYPE%"=="true" (
:: copies files
cd %FOLDERFORADD%
xcopy %WorkDir%\%FOLDERFORADD% %MTRMP% /s /e
cd %WorkDir%

cd %SCRIPTS%
::remove files
call 01_DropExtraFiles.bat
cd %WorkDir%

IF /I "%DB_TYPE%"=="mssql" (
cd MSSQL
@echo MSSQL will be upgrade
call runUpgradeScriptMssql.bat
dir

)

IF /I "%DB_TYPE%"=="oracle" (
cd Oracle
@echo Oracle will be upgrade
call runUpgradeScriptOracle.bat

)
) ELSE (
echo.
@echo !!! You need specifiy DB type whether MSSQL or Oracle !!!
echo.
GOTO ASKUSER
)


:DONE
popd

echo.
echo DONE.
pause