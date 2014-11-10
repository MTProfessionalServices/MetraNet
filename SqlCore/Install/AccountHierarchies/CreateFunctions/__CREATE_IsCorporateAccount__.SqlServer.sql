
		    create FUNCTION IsCorporateAccount(
				@id_acc int,@RefDate Datetime) returns INT
				as
				begin
				  declare @retval int
          select @retval = b_IsCorporate 
	          from t_account_type atype
     	      inner join t_account acc on acc.id_type = atype.id_type
	          where acc.id_acc = @id_acc
				  return @retval
				end
			 