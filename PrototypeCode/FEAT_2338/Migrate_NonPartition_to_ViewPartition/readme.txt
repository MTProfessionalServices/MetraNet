The folder contains scripts for upgrade NON-PARTITION DB to VIEW PARTITION DB
 HOW TO:
 1. Before execution upgrade script, please specify the date from which data in DB will be partitioned.  
    (update date in \04_Data\InsertUsageServerData.sql for [dt_last_interval_creation] field)
 1. RUN runUpgradeNonDbToViewPartitionDb.bat to ubgrqade DB
 2. Execute folowing sp for migrate NON-PARTITION DB to VIEW PARTITION DB:
	a. CreateUsagePartitions
	b. DeployAllPartitionedTables
	
After script's execution DB should be in VIEW partitoning


*) Use RemoveViewPartitionDBs.sql.txt for removing View Partitioned DB