This is manual how to upgrade MetraNet 7.0.2 to  MetraNet 7.1.0 MSSQL DB and remove extra queries which were remove after implementation MetraNet 7.1.0

1. run DropExtraFiles.bat to remove extra queries
2. runUpgradeScript.bat to upgrade DB from 7.0.2 to 7.1.0
3. To verify upgrade executioin see sql_upgrade.log and sql_upgrade_stage.log files