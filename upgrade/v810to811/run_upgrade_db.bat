@echo OFF
@echo ***  Upgrade script for MetraNet  ***
@echo Runs script to Upgrade DB according to specified DB type
@echo.
SET WorkDir=%~dp0

:ASK_USER
SET DB_TYPE=%1%
IF "none%DB_TYPE%"=="none" SET /P DB_TYPE="Specify 'MSSQL' or 'Oracle' upgrade: "

SET ISSETDBTYPE=false

IF /I "%DB_TYPE%"=="mssql" SET ISSETDBTYPE=true
IF /I "%DB_TYPE%"=="oracle" SET ISSETDBTYPE=true

IF "%ISSETDBTYPE%"=="true" (
  pushd %WorkDir%
  echo '%DB_TYPE%' DB will be upgraded
  cd %DB_TYPE%
  call RunUpgradeScript.bat
  popd
) ELSE (
  echo.
  @echo !!! You need specify DB type whether MSSQL or Oracle !!!
  echo.
  GOTO ASK_USER
)

:DONE
popd

echo.
echo DONE.
pause