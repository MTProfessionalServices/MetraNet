
		SELECT partition_scheme = ps.name
		FROM   sys.partition_schemes ps
		WHERE  ps.name = dbo.prtn_GetMeterPartitionSchemaName()
		