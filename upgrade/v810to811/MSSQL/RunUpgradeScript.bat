@echo OFF
SET SQL_CMD="c:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe"

SET WorkDir=%~dp0

pushd %WorkDir%

SET UserName=%1%
IF "none%UserName%"=="none" SET /P UserName="Enter User name[ by default "sa"]: "
IF "none%UserName%"=="none" SET UserName=sa

SET Password=%2%
IF "none%Password%"=="none" SET /P PASSWORD="Enter Password [ by default "MetraTech1" ]: "
IF "none%Password%"=="none" SET PASSWORD=MetraTech1

SET MSSQLServer=%3%
IF "none%MSSQLServer%"=="none" SET /P MSSQLServer="Enter MSSQL server name [ by default "localhost" ]: "
IF "none%MSSQLServer%"=="none" SET MSSQLServer=localhost

SET DBName=%4%
IF "none%DBName%"=="none" SET /P DBName="Enter Database name [ by default "NetMeter" ]: "
IF "none%DBName%"=="none" SET DBName=NetMeter

SET StageDBName=%5%
IF "none%StageDBName%"=="none" SET /P StageDBName="Enter Stage Database name [ by default "NetMeter_Stage" ]: "
IF "none%StageDBName%"=="none" SET StageDBName=NetMeter_Stage

REM use own exitcode variable, because %errorlevel% doesn't work properly
set exitcode=0 

echo.
echo Process scripts in current folder...
FOR /R %%F IN (*.NetMeter.sql) DO (
  @echo   Executes script '%%~nxF'
  %SQL_CMD% -b -S %MSSQLServer% -U %UserName% -P %Password% -d %DBName% -i "%%F" -o "%%~pFLOG-%%~nF.log"
  if ERRORLEVEL 1 goto error
)

FOR /R %%F IN (*.NetMeterStage.sql) DO (
  @echo   Executes script '%%~nxF'
  %SQL_CMD% -S %MSSQLServer% -U %UserName% -P %Password% -d %DBName% -i "%%F" -o "%%~pFLOG-%%~nF.log" -b
  if ERRORLEVEL 1 goto error
)
echo.
echo The upgrade operation has been completed.
@goto done

:error
echo.
echo The upgrade operation has FAILED.
echo To verify upgrade execution see '%WorkDir%LOG-*.log' files!
SET exitcode=1 

:done
popd
@exit /b %exitcode%
