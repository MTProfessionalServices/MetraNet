INSERT INTO [dbo].[t_usage_server]
           ([n_adv_interval_creation]
           ,[dt_last_interval_creation]
           ,[b_partitioning_enabled]
           ,[partition_cycle]
           ,[partition_type]
           ,[partition_data_size]
           ,[partition_log_size])
     VALUES
           (7
           ,'2003-11-03 06:23:00.000'
           ,'Y'
           ,33
           ,'Monthly'
           ,100
           ,25)