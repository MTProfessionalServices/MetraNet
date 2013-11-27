@echo OFF
SET UserId=%1%
IF "none%UserId%"=="none" SET /P UserId="Enter UserId (DB name) [ by default "msukhovarov_FEAT_313"]: "
IF "none%UserId%"=="none" SET UserId=msukhovarov_FEAT_313

SET Password=%2%
IF "none%Password%"=="none" SET /P PASSWORD="Enter Password [ by default "MetraTech1" ]: "
IF "none%Password%"=="none" SET PASSWORD=MetraTech1

SET OracleServer=%2%
IF "none%OracleServer%"=="none" SET /P OracleServer="Enter Oracle server name [ by default "VMORA11Gr2" ]: "
IF "none%OracleServer%"=="none" SET OracleServer=VMORA11Gr2

SET CurrentDir=%CD%
SET WorkDir=c:\dev\MetraNetDEV\PrototypeCode\FEAT_313_DataExportFrameworkSupportOracle\TestData\ORACLE

cd %WorkDir%

FOR /R %%s IN (*.sql) DO (
@echo =====================================
@echo Reads script FROM  '%%~s'
call ECHO exit | sqlplus %UserId%/%PASSWORD%@%OracleServer% @%%~s
)

cd %CurrentDir%

pause