--------------------------------------------------------------------------------------------------
-- NOTE: Users are not included in the backup.
--       Delete all existing Great Plains users before restoring the backup
--       since they will not be functional, but prevent creation of other users with same name.
--
-- to view content of backup run:
--   restore filelistonly from disk='C:\MTGPServerBackup\DYNAMICS'
--   restore filelistonly from disk='C:\MTGPServerBackup\MTGP'
--
-- if the physical name of the database differs from the backup (C:\Program Files\Microsoft SQL Server\MSSQL\data\...)
-- uncomment the use the MOVE options to specify the new physical name 
--------------------------------------------------------------------------------------------------

USE master
if (select count(*) from sysdevices where name = 'DYNAMICS') > 0
     EXEC sp_dropdevice 'DYNAMICS'
EXEC sp_addumpdevice 'disk', 'DYNAMICS', 'C:\MTGPServerBackup\DYNAMICS'
RESTORE DATABASE DYNAMICS FROM DYNAMICS
   WITH RECOVERY
-- ,MOVE 'GPSDYNAMICSDat.mdf' TO 'F:\MSSQL\Data\GPSDYNAMICSDat.mdf'
-- ,MOVE 'GPSDYNAMICSLog.ldf' TO 'F:\MSSQL\Data\GPSDYNAMICSLog.ldf'


USE master
if (select count(*) from sysdevices where name = 'MTGP') > 0 
     EXEC sp_dropdevice 'MTGP'
EXEC sp_addumpdevice 'disk', 'MTGP', 'C:\MTGPServerBackup\MTGP'
RESTORE DATABASE MTGP FROM MTGP
   WITH RECOVERY
-- , MOVE 'MTGPDat.mdf' TO 'F:\MSSQL\Data\GPSMTGPDat.mdf'
-- , MOVE 'MTGPLog.ldf' TO 'F:\MSSQL\Data\GPSMTGPLog.ldf'

