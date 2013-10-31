This is manual how to upgrade MetraNet 7.0.1 to  MetraNet 7.0.2 Oracle DB and remove extra queries which were remove after implementation MetraNet 7.0.2

1. Run 02_DropExtraFiles.bat to remove extra queries;
2. Run 03_runUpgradeScript.bat to upgrade DB from 7.0.1 to 7.0.2;
3. To verify upgrade executioin see upgrade_ora_701_702.log file;
4. Execute sql from "04_vw_aj_info.sql" file in any Oracle IDE (SQL Developer, Sql Navigator, Toad ect.).
