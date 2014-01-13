
	create function MTComputeEffectiveEndDate(@type as int, @offset as int, @base as datetime,  
	@sub_begin datetime, @id_usage_cycle int) returns datetime  
	as
	begin  
	if (@type = 1)  
	begin  
	return @base
	end  
	else if (@type = 2)  
	begin   
	return dbo.MTEndOfDay(@sub_begin + @offset)
	end  
	else if (@type = 3)  
	begin  
	declare @current_interval_end datetime  
	select @current_interval_end = dt_end from t_pc_interval where @base between dt_start and dt_end and id_cycle = @id_usage_cycle  
	return @current_interval_end
	end  
	return null
	end  
		