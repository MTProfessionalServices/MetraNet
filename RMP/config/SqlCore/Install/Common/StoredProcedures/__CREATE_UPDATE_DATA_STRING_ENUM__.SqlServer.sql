
        CREATE PROCEDURE UpdateDataForStringToEnum
        @table varchar(200),
        @column varchar(200),
        @enum_string varchar(200)
        AS
        -- Check for NULLs
        DECLARE @query varchar(1000)
        DECLARE  @query1 varchar(1000)
        SET  @query1 = 'IF (select sum(case when ' +@column +' is null then 0 else 1 end)  from (select distinct ' +'''' +@enum_string +'/' +'''+' +@column +' mydata, ' +@column +' from ' +@table +' ) data '
        SET  @query1 = @query1 +' where not exists (select ''x'' from t_enum_data where nm_enum_data = data.mydata)) is not null BEGIN RAISERROR(''NULL or invalid value found for column ' + @column + ' while converting string to enum'',16,1)  END'
        exec(@query1)
        SET @query = 'update ' + @table +' set ' + @column +'= (select id_enum_data from t_enum_data WHERE nm_enum_data = ' +'''' + @enum_string + '/'' + ' + @column + ')'
        exec (@query)
      