
		create function OverlappingDateRange(@dt_start as datetime,
		  @dt_end as datetime,
			@dt_checkstart as datetime,
			@dt_checkend as datetime) returns integer
			as 
			begin
               if (@dt_start is not null and @dt_start > @dt_checkend) OR
               (@dt_checkstart is not null and @dt_checkstart > @dt_end)
               begin			   
               return (0)
               end
               return (1)
               end
	