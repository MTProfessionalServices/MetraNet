
				create function IsAccountBillable(@id_acc int) 
        returns varchar
		    as
        begin
	      declare @billableFlag as char(1)
		    select @billableFlag = c_billable  from t_av_internal where 
		    id_acc = @id_acc
		    if (@billableFlag is NULL) 
					begin
		      select @billableFlag = '0'
          end  
		    return (@billableFlag)
		    end
				