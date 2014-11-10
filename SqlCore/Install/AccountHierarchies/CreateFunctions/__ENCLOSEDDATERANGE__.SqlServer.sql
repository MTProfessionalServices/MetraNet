
				create function EnclosedDateRange(@dt_start datetime,
	      @dt_end datetime,
  			@dt_checkstart datetime,
				@dt_checkend datetime) returns int
				as
				begin
        declare @test as int
				 -- check if the range specified by temp_dt_checkstart and
				 -- temp_dt_checkend is completely inside the range specified
				 -- by temp_dt_start, temp_dt_end
				if (@dt_checkstart >= @dt_start AND @dt_checkend <= @dt_end ) 
					begin
			    select @test=1
			    end
        else
					begin
          select @test=0
				  end
        return(@test)
        end
				