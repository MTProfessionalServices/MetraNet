@echo OFF

SET ExecScriptStmt=%1%
SET ExecStageScriptStmt=%2%
SET CurrentDir=%CD%
SET WorkDir=%~dp0

FOR /D %%q IN (0*) DO (
@echo *************************************
@echo Into '%WorkDir%%%q' folder
cd %WorkDir%
cd %%q
FOR /R %%s IN (*.sql) DO (
@echo 
@echo =====================================
@echo Reads script FROM  '%%~s'
@echo exit | sqlplus %ExecScriptStmt% @%%~s
)
)

@echo 
@echo =====================================
@echo Reads script FROM  '%WorkDir%\upgradeStageDb.sql'
@echo exit | sqlplus %ExecStageScriptStmt% @%WorkDir%\upgradeStageDb.sql

cd %CurrentDir%
