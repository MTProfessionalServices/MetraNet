BEGIN
	DECLARE @count_fg_from_partition INT,
			@count_fg_from_filegroups INT
					
	SELECT @count_fg_from_partition = COUNT(*) FROM t_partition tp
				
	SELECT @count_fg_from_filegroups = COUNT(*) 
	FROM sys.partition_schemes ps
		INNER JOIN sys.destination_data_spaces dds
			ON dds.partition_scheme_id = ps.data_space_id
		INNER JOIN sys.filegroups fg 
			ON fg.data_space_id =  dds.data_space_id
		LEFT JOIN sys.partition_range_values prv 
			ON prv.boundary_id = dds.destination_id
				AND prv.function_id = ps.function_id
		LEFT JOIN sysfiles sf 
			ON sf.name = fg.name
		INNER JOIN t_partition tp
			ON fg.name =tp.partition_name
	WHERE ps.name = dbo.prtn_GetUsagePartitionSchemaName()
																											 
	IF (@count_fg_from_partition <> @count_fg_from_filegroups)
		SELECT check_usage_filegroups = 'N'
	ELSE
		SELECT check_usage_filegroups = 'Y'
END