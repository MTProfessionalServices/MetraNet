@echo off
echo Starting removing extra files from MetraNet 701

cd /D %MTRMP%\Config\SqlCore\Install\Quoting\StoredProcedures

del __CREATE_MTSP_GENERATE_STATEFUL_NRCS_FOR_QUOTING__._Info.xml
del __CREATE_MTSP_GENERATE_STATEFUL_NRCS_FOR_QUOTING__.Oracle.sql
del __CREATE_MTSP_GENERATE_STATEFUL_NRCS_FOR_QUOTING__.SqlServer.sql

cd /D %MTRMP%\Config\SqlCore\Install\RecurringCharges\StoredProcedures\
del __CREATE_MTSP_GENERATE_STATEFUL_RCS_FOR_QUOTING__._Info.xml
del __CREATE_MTSP_GENERATE_STATEFUL_RCS_FOR_QUOTING__.SqlServer.sql
del __CREATE_MTSP_GENERATE_STATEFUL_RCS_FOR_QUOTING__.Oracle.sql

echo Finished removing extra files from MetraNet 701
pause