
				create table t_updatestatsinfo
				(
				ObjectName nvarchar2(2000),
				StatPercentChar	nvarchar2(2000),
				Duration number(10)
				);
				create index idx_updatestatsinfo on t_updatestatsinfo(objectname);

