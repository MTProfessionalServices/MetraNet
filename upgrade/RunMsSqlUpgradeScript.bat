@echo OFF

SET WorkDir=%~dp0

pushd %WorkDir%

SET FolderName=%1%
IF "none%FolderName%"=="none" SET /P FolderName="Enter Folder name[ by default the last folder]: "
IF "none%FolderName%"=="none" (FOR /D %%q IN (v*) DO SET FolderName=%%q)

SET UserName=%2%
IF "none%UserName%"=="none" SET /P UserName="Enter User name[ by default "sa"]: "
IF "none%UserName%"=="none" SET UserName=sa

SET Password=%3%
IF "none%Password%"=="none" SET /P PASSWORD="Enter Password [ by default "MetraTech1" ]: "
IF "none%Password%"=="none" SET PASSWORD=MetraTech1

SET MSSQLServer=%4%
IF "none%MSSQLServer%"=="none" SET /P MSSQLServer="Enter MSSQL server name [ by default "localhost" ]: "
IF "none%MSSQLServer%"=="none" SET MSSQLServer=localhost

SET DBName=%5%
IF "none%DBName%"=="none" SET /P DBName="Enter Database name [ by default "NetMeter" ]: "
IF "none%DBName%"=="none" SET DBName=NetMeter

SET StageDBName=%6%
IF "none%StageDBName%"=="none" SET /P StageDBName="Enter Stage Database name [ by default "NetMeter_Stage" ]: "
IF "none%StageDBName%"=="none" SET StageDBName=NetMeter_Stage

SET SQL_CMD="c:\Program Files\Microsoft SQL Server\110\Tools\Binn\\sqlcmd"

pushd %WorkDir%%FolderName%\MSSQL

echo.
echo Process folder '%FolderName%'...
echo Run NetMeter upgrade scripts (*.NetMeter.sql).
FOR /R %%F IN (*.NetMeter.sql) DO (
  @echo   Executes script '%%~nxF'
  %SQL_CMD% -S %MSSQLServer% -U %UserName% -P %Password% -d %DBName% -i "%%F" -o "%%F.log"
)

echo.
echo Run NetMeter_Stage upgrade scripts (*.NetMeterStage.sql).
FOR /R %%F IN (*.NetMeterStage.sql) DO (
  @echo   Executes script '%%~nxF'
  %SQL_CMD% -S %MSSQLServer% -U %UserName% -P %Password% -d %DBName% -i "%%F" -o "%%F.log"
)
popd

popd

echo.
echo The upgrade operation has beeb completed.
echo To verify upgrade execution see log-files.
pause