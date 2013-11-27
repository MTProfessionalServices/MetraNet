
		BEGIN
		declare @ExpectedIntervals as int
		declare @ActualIntervals as int
		select @ExpectedIntervals = COUNT (distinct (id_usage_interval)) from %%%NETMETER_PREFIX%%%t_acc_usage_Interval
		select @ActualIntervals = COUNT (distinct (id_interval)) from %%%NETMETER_PREFIX%%%t_partition_interval_map
		if (@ActualIntervals > @ExpectedIntervals)
			begin
			raiserror('There are more entries in partition map table (%d) than expected (%d)', 16, 1, @ActualIntervals, @ExpectedIntervals)
			return
			end
		else if (@ActualIntervals < @ExpectedIntervals)
			begin 
			raiserror('There are less entries in partition map table (%d) than expected (%d)', 16, 1, @ActualIntervals, @ExpectedIntervals)
			return
			end
		END
		