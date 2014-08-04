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

del __PRTN_CREATE_PARTITIONED_TABLE__._Info.xml
del __PRTN_CREATE_PARTITIONED_TABLE__.SqlServer.sql

del __PRTN_CREATE_PARTITION_SCHEMA__._Info.xml
del __PRTN_CREATE_PARTITION_SCHEMA__.SqlServer.sql

del __PRTN_ADD_FILE_GROUP__._Info.xml
del __PRTN_ADD_FILE_GROUP__.SqlServer.sql

del __PRTN_ALTER_PARTITION_SCHEMA__._Info.xml
del __PRTN_ALTER_PARTITION_SCHEMA__.SqlServer.sql

del __PRTN_CREATE_METER_PARTITION_SCHEMA__._Info.xml
del __PRTN_CREATE_METER_PARTITION_SCHEMA__.SqlServer.sql

del __PRTN_DEPLOY_SVC_PARTITIONED_TABLE_SP__._Info.xml
del __PRTN_DEPLOY_SVC_PARTITIONED_TABLE_SP__.SqlServer.sql

del __PRTN_GET_NEXT_ALLOW_RUN_DATE__._Info.xml
del __PRTN_GET_NEXT_ALLOW_RUN_DATE__.SqlServer.sql

cd /D %MTRMP%\Config\SqlCore\Install\Quoting\StoredProcedures

del __CREATE_REMOVEGROUPSUBSCRIPTION_QUOTING__._Info.xml
del __CREATE_REMOVEGROUPSUBSCRIPTION_QUOTING__.Oracle.sql
del __CREATE_MTSP_GENERATE_STATEFUL_NRCS_FOR_QUOTING__.SqlServer.sql

echo Finished removing extra files.
pause