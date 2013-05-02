
	create function MTComputeEffectiveBeginDate(@type as int, @offset as int, @base as datetime,  
	@sub_begin datetime, @id_usage_cycle int) returns datetime  
	as
	begin  
	if (@type = 1)  
	begin  
	return @base  
	end  
	else if (@type = 2)  
	begin   
	return @sub_begin + @offset  
	end  
	else if (@type = 3)  
	begin  
	declare @next_interval_begin datetime  
	select @next_interval_begin = DATEADD(second, 1, dt_end) from t_pc_interval where @base between dt_start and dt_end and id_cycle = @id_usage_cycle  
	return @next_interval_begin  
	end  
	return null  
	end  
		