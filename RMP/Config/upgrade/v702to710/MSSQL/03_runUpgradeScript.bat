@echo OFF
@echo *************************************
@echo
@echo The script is going to upgrade MetraNet 7.0.2 to  MetraNet 7.1.0 MSSQL DB ...
@echo
@echo *************************************
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

SET BCP_FOLDER="c:\Program Files\Microsoft SQL Server\110\Tools\Binn\"

SET CurrentDir=%CD%
SET WorkDir=%~dp0

FOR /D %%q IN (0*) DO (
@echo *************************************
@echo Into '%WorkDir%%%q' folder
cd %WorkDir%
cd %%q
FOR /R %%s IN (*.sql) DO (
@echo =====================================
@echo Reads script FROM  '%%~s'
%BCP_FOLDER%\sqlcmd -S %MSSQLServer% -U %UserName% -P %Password% -d %DBName% -i %%~s -o %WorkDir%\sql_upgrade.log
)
)

rem %BCP_FOLDER%\sqlcmd -S %MSSQLServer% -U %UserName% -P %Password% -d %StageDBName% -i %WorkDir%\upgradeStageDb.sql -o %WorkDir%\sql_upgrade_stage.log


cd %CurrentDir%
echo please, review the log file "%WorkDir%\sql_upgrade_stage.log"

pause