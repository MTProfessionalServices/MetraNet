
					create function LookupAccount(@login nvarchar(255),@namespace nvarchar(40)) 
					returns int
					as
					begin
					declare @retval as int
					select @retval = id_acc  from t_account_mapper 
					where nm_login = @login AND
					lower(@namespace) = nm_space
					if @retval is null
					  begin
						set @retval = -1
					  end
					return @retval
					end

				