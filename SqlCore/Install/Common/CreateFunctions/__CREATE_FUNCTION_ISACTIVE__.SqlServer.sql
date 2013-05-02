
                  create FUNCTION IsActive(@state varchar(2)) returns int
                  as
                  begin
                  declare @retval as int
	          if (@state = 'AC')
                        begin
		        select @retval = 1
                        end
	          else
                        begin
		        select @retval = 0
                        end
	          return @retval
                  end
  