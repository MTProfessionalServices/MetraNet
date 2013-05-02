
		BEGIN
		DECLARE @partition_name NVARCHAR(50),
		@id_interval_start INT,
		@id_intervar_end INT,		
		@count_part INT,
		@count_common INT,
		@partitionNumber INT,
		@test_result NVARCHAR = 'Y'

		DECLARE partcur CURSOR FOR
			SELECT id_interval_start, id_interval_end, partition_name
			FROM t_partition

		OPEN partcur
		FETCH NEXT FROM partcur INTO @id_interval_start, @id_intervar_end, @partition_name
		WHILE (@@FETCH_STATUS = 0)
		BEGIN	
			SELECT @count_common = COUNT(*) 
				FROM %%PART_TABLE%% pt 
			WHERE pt.id_usage_interval BETWEEN @id_interval_start AND @id_intervar_end
			AND pt.id_sess IN (SELECT id_sess FROM %%TABLE_WITH_TEST_IDSESS%%)								
				
			SELECT @partitionNumber = p.partition_number 
			FROM sys.partitions p 
			   INNER JOIN sys.allocation_units au 
					ON au.container_id = p.hobt_id 
			   INNER JOIN sys.filegroups fg 
					ON fg.data_space_id = au.data_space_id 
			WHERE p.object_id = OBJECT_ID('%%PART_TABLE%%') AND fg.name = @partition_name
				
			SELECT @count_part = COUNT(*) 
				FROM %%PART_TABLE%% pt
			WHERE $PARTITION.UsagePartitionFunction(id_usage_interval) = @partitionNumber	
			AND pt.id_sess IN (SELECT id_sess FROM %%TABLE_WITH_TEST_IDSESS%%)
			
			IF @count_common <> @count_part
				SET @test_result = 'N'
				
			FETCH NEXT FROM partcur INTO @id_interval_start, @id_intervar_end, @partition_name
		END

		CLOSE partcur
		DEALLOCATE partcur

		SELECT @test_result
		
		END
		