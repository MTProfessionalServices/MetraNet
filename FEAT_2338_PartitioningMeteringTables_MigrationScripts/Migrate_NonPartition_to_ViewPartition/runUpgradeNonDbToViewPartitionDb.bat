@echo OFF
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
IF "none%DBName%"=="none" SET /P DBName="Enter MSSQL server name [ by default "NetMeter" ]: "
IF "none%DBName%"=="none" SET DBName=NetMeter

SET BCP_FOLDER="c:\Program Files\Microsoft SQL Server\100\Tools\Binn\"

SET CurrentDir=%CD%
::SET WorkDir=c:\dev\Current\PrototypeCode\FEAT_2338_PartitioningMeteringTables\

cd %WorkDir%

FOR /R %%s IN (*.sql) DO (
@echo =====================================
@echo Reads script FROM  '%%~s'
%BCP_FOLDER%\sqlcmd -S %MSSQLServer% -U %UserName% -P %Password% -d %DBName% -i %%~s
)

cd %CurrentDir%

pause