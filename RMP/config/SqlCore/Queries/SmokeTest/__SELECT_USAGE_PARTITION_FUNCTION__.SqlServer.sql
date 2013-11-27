
		SELECT partition_function = pf.name
		FROM   sys.partition_functions pf
		WHERE  pf.name = dbo.prtn_GetUsagePartitionFunctionName()
		