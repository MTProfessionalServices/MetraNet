@echo OFF

SET WorkDir=%~dp0

pushd %WorkDir%

SET UserName=%1%
IF "none%UserName%"=="none" SET /P UserName="Enter User(Schema) name[ by default "NETMETER"]: "
IF "none%UserName%"=="none" SET UserName=NETMETER

SET Password=%2%
IF "none%Password%"=="none" SET /P PASSWORD="Enter Password [ by default "MetraTech1" ]: "
IF "none%Password%"=="none" SET PASSWORD=MetraTech1

SET OracleServer=%3%
IF "none%OracleServer%"=="none" SET /P OracleServer="Enter Oracle server name [ by default "localhost" ]: "
IF "none%OracleServer%"=="none" SET OracleServer=localhost

SET StageDbName=%4%
IF "none%StageDbName%"=="none" SET /P StageDbName="Enter Stage User(Schema) name[ by default "NETMETER_STAGE"]: "
IF "none%StageDbName%"=="none" SET StageDbName=NETMETER_STAGE

SET LocalOracleTnsName=MT

IF %OracleServer%==localhost (
SET "SqlPlusStmt=%UserName%/%Password%@%LocalOracleTnsName%"
SET "SqlPlusStageStmt=%StageDbName%/%Password%@%LocalOracleTnsName%"
) ELSE (
SET "SqlPlusStmt=%UserName%/%Password%@%OracleServer%:1521/netmeter"
SET "SqlPlusStageStmt=%StageDbName%/%Password%@%OracleServer%:1521/netmeter"
)

REM use own exitcode variable, because %errorlevel% doesn't work properly
set exitcode=0 

echo.
echo Process scripts in current folder...
FOR /R %%F IN (*.NetMeter.sql) DO (
  @echo   Executes script '%%~nxF'
  @echo exit | sqlplus %SqlPlusStmt% @%%~F >"%%~pFLOG-%%~nF.log"
  IF ERRORLEVEL 1 goto error
)

FOR /R %%F IN (*.NetMeterStage.sql) DO (
  @echo   Executes script '%%~nxF'
  @echo exit | sqlplus %SqlPlusStmt% @%%~F >"%%~pFLOG-%%~nF.log"
  IF ERRORLEVEL 1 goto error
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
