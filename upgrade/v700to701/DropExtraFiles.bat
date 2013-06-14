@echo off
echo Starting removing extra files from MetraNet 700

cd /D %MTRMP%\Config\SqlCore\Install\Pipeline\CreateTables

del __CREATE_TABLE_T_ARCHIVE_QUEUE_PARTITION__._Info.xml
del __CREATE_TABLE_T_ARCHIVE_QUEUE_PARTITION__.SqlServer.sql

cd ..\StoredProcedures
del __PRTN_GET_NEXT_ALLOW_RUN_DATE__._Info.xml
del __PRTN_GET_NEXT_ALLOW_RUN_DATE__.SqlServer.sql

echo Finished removing extra files from MetraNet 700
pause