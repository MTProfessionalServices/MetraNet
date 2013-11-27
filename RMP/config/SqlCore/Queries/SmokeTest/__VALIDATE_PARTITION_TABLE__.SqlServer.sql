
		BEGIN
			declare @min_date datetime 
			declare @max_date datetime
			select @min_date=min(pc.dt_end), @max_date=max(pc.dt_end) from %%%NETMETER_PREFIX%%%t_pc_interval pc
			inner join %%%NETMETER_PREFIX%%%t_acc_usage_Interval aui on aui.id_usage_interval=pc.id_interval

			select 
			'N_' + replace(convert(varchar, dt_start, 102), '.','') + '_' + replace(convert(varchar, dt_end, 102),'.','') as partition_name,
			dt_start, dt_end,
			datediff(d, '1970-1-1', dt_start) * power(2,16) as id_interval_start,
			datediff(d, '1970-1-1', dt_end) * power(2,16) + (power(2,16) - 1)  as id_interval_end 
			into #tmp_partitions
			from  %%%NETMETER_PREFIX%%%t_pc_interval
			where dt_start >= datediff(d, '23:59:59.000', @min_date)
			and dt_start <= @max_date
			and id_cycle=%%CYCLE_ID%% 

			-- Special case: sometimes the first partion start date is the start date of the previous default partition
			-- The previous default partition start date is passed in. This happens for partital partitions.
			insert into #tmp_partitions
			select 'N_' + replace(convert(varchar, %%PARTIAL_PARTITION_START_DATE%%, 102),'.','') + '_' + replace(convert(varchar, dt_end, 102),'.','') as partition_name,
			%%PARTIAL_PARTITION_START_DATE%%, dt_end,
			datediff(d, '1970-1-1', %%PARTIAL_PARTITION_START_DATE%%) * power(2,16) as id_interval_start,
			datediff(d, '1970-1-1', dt_end) * power(2,16) + (power(2,16) - 1)  as id_interval_end 
			from #tmp_partitions where %%PARTIAL_PARTITION_START_DATE%% >= dt_start and %%PARTIAL_PARTITION_START_DATE%% <=dt_end

			select b_default, partition_name, dt_start, dt_end, id_interval_start, id_interval_end from %%%NETMETER_PREFIX%%%t_partition pp
			where NOT EXISTS (select 1 from #tmp_partitions tmp_pp
					where 
					tmp_pp.partition_name = pp.partition_name
					and tmp_pp.dt_start = pp.dt_start
					and tmp_pp.dt_end = pp.dt_end
					and tmp_pp.id_interval_start = pp.id_interval_start
					and tmp_pp.id_interval_end = pp.id_interval_end
					)
			drop table #tmp_partitions
		END
		