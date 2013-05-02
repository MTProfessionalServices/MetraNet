
				create proc InsertUsageCycleInfo @id_cycle_type int, @dom int,
          @period_type char(1), @id_usage_cycle int OUTPUT
				as
        insert into t_usage_cycle (id_cycle_type, day_of_month, tx_period_type)
          values (@id_cycle_type, @dom, @period_type)
        if ((@@error != 0) OR (@@rowcount != 1))
        begin
          select @id_usage_cycle = -99
        end
        else
        begin
          select @id_usage_cycle = @@identity
        end
			 