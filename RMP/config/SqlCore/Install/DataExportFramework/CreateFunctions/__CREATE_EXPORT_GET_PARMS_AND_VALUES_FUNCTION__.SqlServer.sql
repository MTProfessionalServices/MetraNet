

      create   FUNCTION ExportGetParmsAndValues (@id_rep_instance_id INT) RETURNS VARCHAR(200)
              AS
            BEGIN
            DECLARE @retval AS VARCHAR(200)
                  DECLARE @param_desc VARCHAR(100)
                  DECLARE @param_value VARCHAR(100)
 
                  DECLARE Working_csr CURSOR FOR
                        SELECT c_param_desc, c_param_value 
                        FROM t_export_default_param_values PARMVALUES
                        INNER JOIN t_export_param_names PARMNAMES ON PARMVALUES.id_param_name = PARMNAMES.id_param_name 
                        WHERE id_rep_instance_id = @id_rep_instance_id
 
                  OPEN Working_csr
 
                  FETCH NEXT FROM Working_csr
                        INTO @param_desc, @param_value
 
                  SET @retval = ''
 
                  WHILE @@FETCH_STATUS = 0
                  BEGIN
                        SET @retval = @retval + CASE @retval WHEN '' THEN '' ELSE ', ' END + @param_desc + ' = ' + @param_value 
 
                        FETCH NEXT FROM Working_csr
                              INTO @param_desc, @param_value
                  END
 
                  CLOSE Working_csr
                  DEALLOCATE Working_csr
 
                  RETURN @retval
      END	 
