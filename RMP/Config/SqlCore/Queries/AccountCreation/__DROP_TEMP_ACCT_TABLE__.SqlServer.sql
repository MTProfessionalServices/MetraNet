
        DECLARE @SQL nvarchar(200)
        SET @SQL = 'drop table ' + @tableName
        EXEC(@SQL)
        