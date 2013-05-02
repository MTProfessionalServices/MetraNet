
				declare @sql_string as varchar(8000)
				exec CreateRefMatchSQL '%%TABLE_NAME%%','%%TABLE_NAME%%1','%%TABLE_NAME%%2',@sql_str = @sql_string OUTPUT
				select @sql_string
			