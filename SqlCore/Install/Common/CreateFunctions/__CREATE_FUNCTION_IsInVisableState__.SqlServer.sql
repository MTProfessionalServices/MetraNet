
              CREATE FUNCTION IsInVisableState(@state varchar(2)) returns int
              as
              begin
              declare @retval int
           -- if the account is closed or archived
	      if (@state <> 'CL' AND @state <> 'AR')
                begin
		select @retval = 1
	        end
              else
		begin
                select @retval = 0
	        end
	      return @retval
              end
        