
			 create proc InsertUsageIntervalInfo @dt_start datetime, @dt_end datetime,@id_usage_cycle int, @id_usage_interval int OUTPUT
			 as
			 select @id_usage_interval = id_interval from t_pc_interval where id_cycle = @id_usage_cycle
			 and dt_start=@dt_start and dt_end=@dt_end

			 insert into t_usage_interval (id_interval, dt_start, dt_end,
			 id_usage_cycle, tx_interval_status)
			   values (@id_usage_interval, @dt_start, @dt_end,@id_usage_cycle, 'O')
			 if ((@@error != 0) OR (@@rowcount != 1))
			 begin
			   select @id_usage_interval = -99
			 end
			 