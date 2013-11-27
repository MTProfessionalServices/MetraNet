@echo OFF
@echo *************************************
@echo
@echo The script is going to upgrade MetraNet 7.0.2 to  MetraNet 7.1.0 Oracle DB ...
@echo
@echo *************************************
SET UserName=%1%
IF "none%UserName%"=="none" SET /P UserName="Enter User name[ by default "NETMETER"]: "
IF "none%UserName%"=="none" SET UserName=NETMETER

SET StageDbName=%1%
IF "none%StageDbName%"=="none" SET /P StageDbName="Enter Stage DB(User) name[ by default "NETMETER_STAGE"]: "
IF "none%StageDbName%"=="none" SET StageDbName=NETMETER_STAGE

SET Password=%2%
IF "none%Password%"=="none" SET /P PASSWORD="Enter Password [ by default "MetraTech1" ]: "
IF "none%Password%"=="none" SET PASSWORD=MetraTech1

SET OracleServer=%3%
IF "none%OracleServer%"=="none" SET /P OracleServer="Enter Oracle server name [ by default "localhost" ]: "
IF "none%OracleServer%"=="none" SET OracleServer=localhost

IF %OracleServer%==localhost (
SET "SqlPlusStmt=%UserName%/%Password%"
SET "SqlPlusStageStmt=%StageDbName%/%Password%"
) ELSE (
SET "SqlPlusStmt=%UserName%/%Password%@%OracleServer%:1521/netmeter"
SET "SqlPlusStageStmt=%StageDbName%/%Password%@%OracleServer%:1521/netmeter"
)

@echo Starting DB Upgrade...

call runUpgradeScript_internal.bat %SqlPlusStmt% %SqlPlusStageStmt% > upgrade_ora_702_710.log

@echo DB Upgrade finished. See results in log file "upgrade_ora_702_710.log"

pause
