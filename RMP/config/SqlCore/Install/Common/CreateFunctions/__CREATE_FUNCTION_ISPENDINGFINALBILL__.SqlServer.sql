
            CREATE FUNCTION IsPendingFinalBill(@state varchar(2)) returns int
              as
              begin
              declare @retval int
	      if (@state = 'PF')
                  begin
		  select @retval = 1
	          end
              else
                  begin
                  select @retval = 0
        	  end
	      return @retval
              end
  