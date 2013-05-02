
			CREATE PROCEDURE RetrieveEnumCode 
			@enum_string varchar(200)
			AS
			BEGIN
				Declare @idEnum INT 
				SELECT @idEnum = id_enum_data FROM t_enum_data  WHERE nm_enum_data = @enum_string
				RETURN @idEnum
			END;
		