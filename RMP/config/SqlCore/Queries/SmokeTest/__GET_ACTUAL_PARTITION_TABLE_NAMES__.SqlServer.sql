			
			SELECT DISTINCT table_name = o.name
			/*
			table_id = o.object_id,
				   table_name = o.name,
				   partition_index_name = i.name,
				   partition_index_type = i.type_desc,
				   partition_scheme = ps.name,
				   partition_function = pf.name,
				   partition_id = p.partition_id,
				   partition_number = p.partition_number,
				   inserted_rows = p.rows
			*/
			FROM   sys.partitions p
				   JOIN sys.objects o
						ON  o.object_id = p.object_id
				   JOIN sys.indexes i
						ON  p.object_id = i.object_id
						AND p.index_id = i.index_id
				   JOIN sys.data_spaces ds
						ON  i.data_space_id = ds.data_space_id
				   JOIN sys.partition_schemes ps
						ON  ds.data_space_id = ps.data_space_id
				   JOIN sys.partition_functions pf
						ON  ps.function_id = pf.function_id
			WHERE	ps.name = dbo.prtn_GetUsagePartitionSchemaName()
					OR ps.name = dbo.prtn_GetMeterPartitionSchemaName()
		