
      CREATE FUNCTION ExportGetProcParms (@proc_name VARCHAR(100)) returns varchar(300)
      AS
    
            BEGIN
            DECLARE @retval AS VARCHAR(300)
                  DECLARE @column_name VARCHAR(100)
                  DECLARE Working_csr CURSOR FOR
                        SELECT B.name
                        FROM sysobjects A, syscolumns B
                        WHERE A.id = B.id
                        AND upper(A.name) = @proc_name      
                        ORDER BY B.colid
 
                  OPEN Working_csr
 
                  FETCH NEXT FROM Working_csr
                        INTO @column_name
 
                  SET @retval = ''
                  WHILE @@FETCH_STATUS = 0 
                  BEGIN
                       SET @retval = @retval + '%' + '%' + @column_name + '%' + '%' + ','
 
                        FETCH NEXT FROM Working_csr
                              INTO @column_name
                  END
 
                  CLOSE Working_csr
                  DEALLOCATE Working_csr
 
                  RETURN REPLACE(SUBSTRING(@retval, 1, (LEN(@retval) - 1)), '@', '')
      END
	 