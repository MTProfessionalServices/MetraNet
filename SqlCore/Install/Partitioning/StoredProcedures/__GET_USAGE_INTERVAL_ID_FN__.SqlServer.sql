
      /*
      	GetUsageIntervalID 
      
      	Calculates and interval id from and end_date and cycle id.
      
      	@dt_end  -- end date of interval
      	@id_cycle -- cycle id of interval
      */
      create function GetUsageIntervalID (
      	@dt_end datetime,
      	@id_cycle int)
      returns int
      as
      begin
      
      	return datediff(day,'1970-01-01', @dt_end) * power(2,16) + @id_cycle
      
      end
 	