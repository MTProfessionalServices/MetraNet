This is manual how to upgrade MetraNet 7.0.2 to  MetraNet 7.1.0 Oracle DB and remove extra queries which were remove after implementation MetraNet 7.1.0

Important: If you don't want performance related changes, that are time-consuming due to indexes recreation
extract "20_Perf_tunning.sql" file out of "001" folder.
You may execute it separately after upgrading DB.

All GLOBAL indexes of meter tables (T_SESSION, T_SESSION_SET, T_SESSION_STATE, T_MESSAGE, T_SVC_*) must be recreated as LOCAL indexes.
This is necessary for performance of Archive_Queue stored procedure.

1. Run 02_DropExtraFiles.bat to remove extra Sql installation files, left from previos version;
2. Run 03_runUpgradeScript.bat to upgrade DB from 7.0.2 to 7.1.0;
3. To verify upgrade executioin see upgrade_ora_702_710.log file;
4. Execute sql from "04_vw_aj_info.sql" file in any Oracle IDE (SQL Developer, Sql Navigator, Toad ect.).
