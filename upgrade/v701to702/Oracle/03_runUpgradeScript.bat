@echo OFF
@echo *************************************
@echo
@echo The script is going to upgrade MetraNet 7.0.1 to  MetraNet 7.0.2 Oracle DB ...
@echo
@echo *************************************
SET UserName=%1%
IF "none%UserName%"=="none" SET /P UserName="Enter User name[ by default "NETMETER"]: "
IF "none%UserName%"=="none" SET UserName=NETMETER

SET Password=%2%
IF "none%Password%"=="none" SET /P PASSWORD="Enter Password [ by default "MetraTech1" ]: "
IF "none%Password%"=="none" SET PASSWORD=MetraTech1

SET OracleServer=%3%
IF "none%OracleServer%"=="none" SET /P OracleServer="Enter Oracle server name [ by default "localhost" ]: "
IF "none%OracleServer%"=="none" SET OracleServer=localhost

IF %OracleServer%==localhost (
SET "SqlPlusStmt=%UserName%/%Password%"
) ELSE (
SET "SqlPlusStmt=%UserName%/%Password%@%OracleServer%:1521/netmeter"
)

@echo Starting DB Upgrade...

call runUpgradeScript_internal.bat %SqlPlusStmt% > upgrade_ora_701_702.log

@echo DB Upgrade finished. See results in log file "upgrade_ora_701_702.log"

pause
