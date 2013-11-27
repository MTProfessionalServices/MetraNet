
		CREATE PROCEDURE FILTERSORTQUERY_v3      (           
			@InnerQuery nvarchar(max),                 
			@OrderByText nvarchar(500),                 
			@StartRow int,                 
			@NumRows int          
		)
		AS           
		BEGIN      
			 
			declare @Sql nvarchar(max)                 
		 
			set @Sql = N' SELECT COUNT(1) as TotalRows FROM (' + @InnerQuery + N') CNTQ;'  
			print @Sql   
			EXEC (@Sql)  
		 
		 
			SET @Sql = 'ROW_NUMBER() OVER (';  
			IF LEN(@OrderByText) > 0  
			BEGIN  
				SET @Sql = @Sql + @OrderByText + ') as RowNumber';  
			END  
			ELSE  
			BEGIN  
				SET @Sql = @Sql + 'ORDER BY (SELECT 1)) as RowNumber';  
			END  
	   
			SET @Sql = 'WITH Q AS (' + 'SELECT *, ' + @Sql + ' FROM (' + @InnerQuery + ') IQ )';  
			SET @Sql = @Sql + 'SELECT * FROM Q ';  
	   
			IF @NumRows > 0  
			BEGIN  
				SET @Sql = @Sql + 'WHERE RowNumber BETWEEN ' + CAST(@StartRow as nvarchar(10)) + ' and ' + CAST((@StartRow + @NumRows - 1) as nvarchar(10));  
			END  
		
			PRINT @Sql;  
			EXEC (@Sql)  
	   
		END
      