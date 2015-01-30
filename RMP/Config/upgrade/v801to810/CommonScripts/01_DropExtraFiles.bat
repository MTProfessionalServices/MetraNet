@echo off
echo Starting removing extra files left from previos MetraNet version: 810

:: as example
:: cd /D %MTRMP%\Config\SqlCore\Install\Partitioning\StoredProcedures\
:: del __CREATE_TAX_DETAIL_PARTITIONS_SP__._Info.xml
::del __CREATE_TAX_DETAIL_PARTITIONS_SP__.SqlServer.sql
::del __CREATE_TAX_DETAIL_PARTITIONS_SP__.Oracle.sql

echo Finished removing extra files.
pause