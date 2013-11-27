
		CREATE procedure AddDatabaseProperty(@property nvarchar(128), @value nvarchar(5))
		as
			delete from t_db_values where parameter=@property
			insert into t_db_values(parameter,value) values(@property,@value)
		