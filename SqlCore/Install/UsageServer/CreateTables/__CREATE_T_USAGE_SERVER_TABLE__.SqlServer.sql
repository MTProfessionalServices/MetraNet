/*
	<initialization table="t_usage_server">
		<insert_only/>
	</initialization>
*/
			CREATE TABLE [t_usage_server] (
				[n_adv_interval_creation] [int] NOT NULL , -- number of days to create intervals in advance
				[dt_last_interval_creation] [datetime] NULL , -- date of last interval creation
				[b_partitioning_enabled] [nvarchar](1) not null default 'N',
				[partition_cycle] [int] not null default 30,
				[partition_type] [nvarchar](20) not null default 'Monthly',
				[partition_data_size] [int] not null default 100,
				[partition_log_size] [int] not null default 25
			) ON [PRIMARY]

