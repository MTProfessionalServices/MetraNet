DECLARE @default_value VARCHAR(50),
		@id_partition_default_value INT
		
SELECT @default_value = cnstr.definition FROM sys.all_columns allclmns
	INNER JOIN sys.tables tbls ON allclmns.object_id = tbls.object_id
	INNER JOIN sys.default_constraints cnstr ON allclmns.default_object_id = cnstr.object_id
	WHERE tbls.name = 't_message' AND allclmns.name = 'id_partition' 
	
SET @default_value = REPLACE(@default_value, '((', '')
SET @default_value = REPLACE(@default_value, '))', '')

SET @id_partition_default_value = CONVERT(INT, @default_value)
	
SELECT @id_partition_default_value
				
		