@echo off
echo Starting removing extra files left from previos MetraNet version: 702

cd /D %MTRMP%\Config\SqlCore\Install\Pipeline\CreateTables\

del __CREATE_PROCEDURE_GETNONARCHIVERECORDS__._Info.xml
del __CREATE_PROCEDURE_GETNONARCHIVERECORDS__.Oracle.sql

cd /D %MTRMP%\Config\SqlCore\Install\Partitioning\StoredProcedures\

del __CREATE_TAX_DETAIL_PARTITIONS_SP__._Info.xml
del __CREATE_TAX_DETAIL_PARTITIONS_SP__.SqlServer.sql
del __CREATE_TAX_DETAIL_PARTITIONS_SP__.Oracle.sql

del __CREATE_USAGE_PARTITIONS_SP__._Info.xml
del __CREATE_USAGE_PARTITIONS_SP__.SqlServer.sql
del __CREATE_USAGE_PARTITIONS_SP__.Oracle.sql

del __DEPLOY_PARTITIONED_TABLE_SP__._Info.xml
del __DEPLOY_PARTITIONED_TABLE_SP__.SqlServer.sql
del __DEPLOY_PARTITIONED_TABLE_SP__.Oracle.sql

del __DEPLOY_ALL_PARTITIONED_TABLES_SP__._Info.xml
del __DEPLOY_ALL_PARTITIONED_TABLES_SP__.SqlServer.sql
del __DEPLOY_ALL_PARTITIONED_TABLES_SP__.Oracle.sql

del __DUP_PARTITIONED_TABLE_SP__._Info.xml
del __DUP_PARTITIONED_TABLE_SP__.Oracle.sql

cd /D %MTRMP%\Config\SqlCore\Install\Quoting\StoredProcedures

del __CREATE_REMOVEGROUPSUBSCRIPTION_QUOTING__._Info.xml
del __CREATE_REMOVEGROUPSUBSCRIPTION_QUOTING__.Oracle.sql

echo Finished removing extra files.
pause