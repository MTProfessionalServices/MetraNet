
			create function MTDateInRange (
                                    @startdate datetime,
                                    @enddate datetime,
                                    @CompareDate datetime)
				returns int
			as
			begin
                                  declare @abc as int
                                  if @startdate <= @CompareDate AND @CompareDate < @enddate 
                                   begin
                                   select @abc = 1
                                   end 
                                else
                                   begin
                                   select @abc = 0
                                   end 
			   return @abc
                           end
		