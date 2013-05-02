
	create function MTRateScheduleScore(@type as int, @begindate datetime) returns int  
	as
	begin  
	declare @datescore int  
	set @datescore = case @type when 4 then 0 else datediff(s, '1970-01-01', isnull(@begindate, '1970-01-01')) end  
	declare @typescore int  
	set @typescore = case @type   
	when 2 then 2   
	when 4 then 0   
	else 1   
	end  
	return cast(@typescore as int) * 0x20000000 + (cast(@datescore as int) / 8)
	end 
		