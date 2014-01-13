SELECT fg.name [file_group_name], ps.name [meter_paririon_schema]
FROM sys.partition_schemes ps
	INNER JOIN sys.destination_data_spaces dds 
		ON dds.partition_scheme_id = ps.data_space_id
	INNER JOIN sys.filegroups fg 
		ON fg.data_space_id =  dds.data_space_id
	LEFT JOIN sys.partition_range_values prv 
		ON prv.boundary_id = dds.destination_id 
			AND prv.function_id = ps.function_id
	LEFT JOIN sysfiles sf ON sf.name = fg.name
WHERE ps.name = dbo.prtn_GetMeterPartitionSchemaName()
		AND fg.name = dbo.prtn_GetMeterPartitionFileGroupName()
GROUP BY fg.name, ps.name