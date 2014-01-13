
             CREATE FUNCTION IsArchived(@state varchar(2)) returns integer
             as
             begin
             declare @retval int
	     if (@state = 'AR')
                 begin
		 select @retval = 1
                 end
	     else
                 begin
		 select @retval = 0
	     end
             return @retval
             end
  