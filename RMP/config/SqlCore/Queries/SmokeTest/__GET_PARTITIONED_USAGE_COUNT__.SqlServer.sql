
		BEGIN
			declare @partition_name as nvarchar(256)
			declare @sql as nvarchar(512)
			declare @interval_dt_end datetime

			select @interval_dt_end = dt_end from %%%NETMETER_PREFIX%%%t_usage_interval
			where id_interval in (select distinct id_usage_interval from
			%%%NETMETER_PREFIX%%%t_acc_usage where dt_session = %%DATA_DATE%%)

			select @partition_name = partition_name from %%%NETMETER_PREFIX%%%t_partition
			where @interval_dt_end >= dt_start and @interval_dt_end <= dt_end and (b_default = 'N' or b_default = 'n')
			
			if (@partition_name is NULL)
			begin
				set @partition_name	= '%%%NETMETER_PREFIX%%%'
			end
						
			set @sql = 'select COUNT(*) as row_count from ' + @partition_name + '..%%PV_TABLE_NAME%%
						where %%TRANSACTION_ID_COLUMN%% = ''%%TRANSACTION_ID%%'' and
						%%DATE_COL_NAME%% = %%START_DATE%%'
			exec (@sql)
		END
		