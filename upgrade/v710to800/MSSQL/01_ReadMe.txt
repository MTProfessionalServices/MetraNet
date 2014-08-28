This is manual how to upgrade MetraNet 7.1.0 to  MetraNet 8.0.0 MSSQL DB

1. Run 02_runUpgradeScript.bat to upgrade DB from 7.1.0 to 8.0.0
2. To verify upgrade execution see Main.NetMeter.log file


Note from Kuchmai Julia.
All steps of upgrade process:
1.	Stop all services, close ICE if it’s installed and opened
2.	Run 02_runUpgradeScript.bat
3.	Verify log file (Main.NetMeter.sql.log) Expected result, last line should be: “The database update succeeded”
4.	In cmd execute:
Bmesync –build
Bmesync –sync
5.	synchronize all hooks 
NOTE: verify that Report Templates and Credit Note Templates hooks are available. Metadata hook should be commented 
6.	Verify that sync was completed successfully and there are no errors in Mtlog and ICE validation (if its installed)
7.	Execute “UpdateAfterHook_t_be_cor_ui_site.sql”
8.  Execute “UpdateAfterSyncAll.sql”