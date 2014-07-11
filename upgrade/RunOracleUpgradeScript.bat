@echo OFF

SET WorkDir=%~dp0

pushd %WorkDir%

SET FolderName=%1%
IF "none%FolderName%"=="none" SET /P FolderName="Enter Folder name[ by default the last folder]: "
IF "none%FolderName%"=="none" (FOR /D %%q IN (v*) DO SET FolderName=%%q)

SET UserName=%2%
IF "none%UserName%"=="none" SET /P UserName="Enter User name[ by default "NETMETER"]: "
IF "none%UserName%"=="none" SET UserName=NETMETER

SET Password=%3%
IF "none%Password%"=="none" SET /P PASSWORD="Enter Password [ by default "MetraTech1" ]: "
IF "none%Password%"=="none" SET PASSWORD=MetraTech1

SET OracleServer=%4%
IF "none%OracleServer%"=="none" SET /P OracleServer="Enter Oracle server name [ by default "localhost" ]: "
IF "none%OracleServer%"=="none" SET OracleServer=localhost

SET StageDbName=%5%
IF "none%StageDbName%"=="none" SET /P StageDbName="Enter Stage DB(User) name[ by default "NETMETER_STAGE"]: "
IF "none%StageDbName%"=="none" SET StageDbName=NETMETER_STAGE


IF %OracleServer%==localhost (
SET "SqlPlusStmt=%UserName%/%Password%"
SET "SqlPlusStageStmt=%StageDbName%/%Password%"
) ELSE (
SET "SqlPlusStmt=%UserName%/%Password%@%OracleServer%:1521/netmeter"
SET "SqlPlusStageStmt=%StageDbName%/%Password%@%OracleServer%:1521/netmeter"
)

pushd %WorkDir%%FolderName%\Oracle

echo.
echo Process folder '%FolderName%'...
echo Run NetMeter upgrade scripts (*.NetMeter.sql).
FOR /R %%F IN (*.NetMeter.sql) DO (
  @echo   Executes script '%%~nxF'
  exit | sqlplus %SqlPlusStmt% @"%%F" >"%%F.log"
)

echo.
echo Run NetMeter_Stage upgrade scripts (*.NetMeterStage.sql).
FOR /R %%F IN (*.NetMeterStage.sql) DO (
  @echo   Executes script '%%~nxF'
  exit | sqlplus %SqlPlusStageStmt% @"%%F" >"%%F.log"
)
popd

popd

echo.
echo The upgrade operation has beeb completed.
echo To verify upgrade execution see log-files.
pause