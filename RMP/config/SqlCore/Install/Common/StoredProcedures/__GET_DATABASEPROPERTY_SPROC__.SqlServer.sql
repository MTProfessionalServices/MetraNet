
		CREATE procedure GetDatabaseProperty(@property nvarchar(128), @value nvarchar(200) output, @status int output)
		as
		select @value=value from t_db_values where parameter = @property
		if (@value Is NULL)
		begin
			set @status = -99
			return
		end
		set @status = 0
    