Steps to upgrade MetraNet 7.1.0 to MetraNet 8.0.0 Oracle DB: 

Scenario #1:
execute script ..\..\RunMsSqlUpgradeScript.bat

Scenario #2:
1. Execute sql from "01.NetMeter.sql" file in any Oracle IDE (SQL Developer, etc.).
2. Execute sql from "02_t_be_cor_qu_CopyData.NetMeter.sql" file in any Oracle IDE (SQL Developer, etc.).
3. Execute sql from "10_SetVersion.NetMeter.sql" file in any Oracle IDE (SQL Developer, etc.).