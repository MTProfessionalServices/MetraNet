The folder contains scripts for upgrade NON-PARTITION DB to NATIVE PARTITION DB
 HOW TO:
 1. Before execution upgrade script, please specify the date from which data in DB will be partitioned.  
    (update date in \04_Data\InsertUsageServerData.sql for [dt_last_interval_creation] field)
 1. RUN runUpgradeNonDbToNativePartitionDb.bat to ubgrqade DB
 2. Execute folowing sp for migrate NON-PARTITION DB to NATIVE PARTITION DB:
	a. CreateUsagePartitions
	b. prtn_CreateMeterPartitionSchema
	c. DeployAllPartitionedTables
	d. prtn_DeployAllMeterPartitionedTables
	
After script's execution DB should be partitoned

Description about versions of archive_queue_partition sp:
051_ArchSP_session_portions - data migrate by session portions (TOP 1000000 - takes 6 iteration) by updating value in partition column. Tested in perf11 and time execution = 23 min

_052_Archive_Procedure_session_portions_with_maxdoop1_and_top_1000 - data migrates by session portions (TOP 1000 - takes 5093 iteration) + maxdoop1 (without parallelism) by updating value in partition column. Tested in perf11 and time execution = 2:18:47

053_ArchSP_by_table_portions - Instead of updating value in partition column the select -> insert operation were implemented, but sesstion porsions was not applicable for the approach so it was rewrited to table portions. Tested in perf11 and time execution = 13 min 

054_ArchSP_switch_out_switch_in - Alex Chapenko's approcah to use preserbed (4-th partition) to avoid locks + Nikita tuned creation of temp table wchi are using in switch in operation. Tested in perf11 and time execution = 8 min 13 sec

P.S. If you want to exclude folder from script just add prefix '_' to the beginning of folder name