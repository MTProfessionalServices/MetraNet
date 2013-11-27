-- NOTE: If this backup is to be stored as the initial MTGPServerBackup
--       make sure to not have: 
--       - no users
--       - no master data
--       - no transactions

USE master
if (select count(*) from sysdevices where name = 'DYNAMICS') > 0
     EXEC sp_dropdevice 'DYNAMICS'
EXEC sp_addumpdevice 'disk', 'DYNAMICS', 'C:\MTGPServerBackup\DYNAMICS'
BACKUP DATABASE DYNAMICS TO DYNAMICS WITH INIT

USE master
if (select count(*) from sysdevices where name = 'MTGP') > 0 
     EXEC sp_dropdevice 'MTGP'
EXEC sp_addumpdevice 'disk', 'MTGP', 'C:\MTGPServerBackup\MTGP'
BACKUP DATABASE MTGP TO MTGP WITH INIT
