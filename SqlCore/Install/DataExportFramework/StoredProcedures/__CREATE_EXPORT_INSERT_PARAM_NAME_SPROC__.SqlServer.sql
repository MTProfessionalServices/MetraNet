
		CREATE PROCEDURE [export_InsertParamName] 
		( 
			@paramName VARCHAR(50),
			@paramDesc VARCHAR(50) = NULL
		)
		AS
		DECLARE
		@errMessage CHAR(50) = CAST(@paramName AS CHAR(50)) + ' parameter already exists in DB.';
			BEGIN

				IF NOT EXISTS(SELECT * FROM t_export_param_names WHERE c_param_name = '%'+'%'+@paramName+'%'+'%')
					INSERT INTO t_export_param_names (c_param_name, c_param_desc) VALUES ('%'+'%'+@paramName+'%'+'%', @paramDesc)
				ELSE					
					RAISERROR(@errMessage, 16, 1)					
			END	 	 
	