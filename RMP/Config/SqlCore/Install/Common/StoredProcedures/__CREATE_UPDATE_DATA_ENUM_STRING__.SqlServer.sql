
			CREATE PROCEDURE UpdateDataForEnumToString
			@table varchar(200),
			@column varchar(200)
			AS

			DECLARE @query varchar(1000)

			SET @query = 'update ' +@table +' set ' +@column +'= (select '
			SET @query = @query + 'REVERSE(SUBSTRING( REVERSE(nm_enum_data),1, CHARINDEX(''/'',REVERSE(nm_enum_data))-1) )'
			SET @query = @query +  ' from t_enum_data WHERE id_enum_data = ' +@column +')'

			exec (@query)
		