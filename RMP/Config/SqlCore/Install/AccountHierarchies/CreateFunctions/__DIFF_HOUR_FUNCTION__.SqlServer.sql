
      create function DiffHour(@dt_start datetime, @dt_end datetime) 
        returns decimal
      as
      begin
       return datediff(hour, @dt_start, @dt_end)
      end
				