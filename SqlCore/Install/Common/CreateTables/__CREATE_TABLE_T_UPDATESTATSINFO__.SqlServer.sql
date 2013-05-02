
				create table t_updatestatsinfo
				(
				ObjectName nvarchar(2000),
				StatPercentChar	nvarchar(2000),
				Duration int
				)
				create clustered index idx_updatestatsinfo on t_updatestatsinfo(objectname)
 	 