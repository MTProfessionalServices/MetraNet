
                create proc AddPartitionsToTaxDetailsTable
                as
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    -- Only consider open and soft-closed intervals
                    declare @intervalStatus varchar(20)
                    set @intervalstatus = '[BO]'

                    -- Get minimum interval start date and and maximum interval end date for all
                    -- of the active intervals (interval status is B or O)
                    declare @minIntervalStartDate datetime
                    declare @maxIntervalEndDate datetime
                    select @minIntervalStartDate=min(dt_start), @maxIntervalEndDate=max(dt_end) 
                        from t_usage_interval ui
                        where ui.tx_interval_status like '[BO]'

                    -- Now we need to create partitions with the specified cycle (e.g. monthly, yearly)
                    -- that will encompass the minIntervalStartDate and maxIntervalEndDate

                    -- Get the partition cycle from t_usage_server.  The cycle was specified
                    -- during installation.
                    -- e.g. daily, weekly, bi-monthly, monthly, quarterly, yearly
                    declare @partitionCycle int
                    select @partitionCycle = partition_cycle from t_usage_server

                    -- The biggest boundary value and convert it into a date
                    -- (Note: the units of lastPartitionStartValue are days since 19700101 shifted left 16 bits)
                    declare @lastPartitionStartValue int
                    SELECT @lastPartitionStartValue=convert(int, max(c_boundary_value)) FROM v_partition_info 
                        WHERE c_object_name='t_tax_details'
                    set @lastPartitionStartValue = @lastPartitionStartValue / 65536
                    
                    declare @partitionStartDate datetime
                    set @partitionStartDate = DATEADD(DAY, @lastPartitionStartValue, '19700101')

                    -- Determine the partitionEndDate given the partitionStartDate and the specified cycle
                    declare @partitionEndDate datetime
                    SELECT @partitionEndDate=min(dt_start) FROM t_pc_interval 
                        WHERE id_cycle=@partitionCycle AND dt_start > @partitionStartDate

                    declare @numPartitionsAdded int
                    set @numPartitionsAdded = 0
                    while (@partitionStartDate < @maxIntervalEndDate)
                    begin
                        set @numPartitionsAdded = @numPartitionsAdded + 1

                        -- Determine a suffix to be used on the fileGroup and the file
                        -- associated with a partition
                        declare @partitionNameSuffix varchar(500)
                        exec GeneratePartitionNameSuffix @partitionStartDate, @partitionEndDate, @partitionNameSuffix out
                        if (@@ERROR <> 0) 
                        begin
                            raiserror('GeneratePartitionNameSuffix failed', 16, 1);
                            return 1
                        end

                        -- Create and execute an add filegroup command e.g.
                        -- "alter database add filegroup fgIntervalId_1013252096_1015283712"
                        declare @fileGroupName varchar(500)
                        exec CreateAndExecuteAddFileGroupCommand 'fg', @partitionNameSuffix, @fileGroupName output
                        if (@@ERROR <> 0) 
                        begin
                            return 1
                        end

                        -- Create and execute an add file command e.g.
                        -- ALTER DATABASE NetMeter ADD FILE
                        -- ( 
                        -- NAME = 'File201205.ndf',
                        -- FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\testFile201205.ndf',
                        -- SIZE = 5MB,
                        -- MAXSIZE = UNLIMITED,
                        -- FILEGROWTH = 5MB
                        -- )
                        -- TO FILEGROUP Fg201205
                        exec CreateAndExecuteAddFileCommand 'file', @partitionNameSuffix, @fileGroupName
                        if (@@ERROR <> 0) 
                        begin
                            return 1
                        end

                        -- Reformat the partitionEndDate to match the format of an interval_id
                        -- which has the days-since-1970101 in the upper 16 bits.
                        declare @endDate int
                        set @endDate = DATEDIFF(DAY, '19700101', @partitionEndDate) * 65536

                        declare @alterCommand varchar(500)
                        set @alterCommand = 'use ' + db_name() + '; ALTER PARTITION SCHEME [psTaxDetails] NEXT USED ' +
                            @fileGroupName;
                        exec(@alterCommand);
                        if (@@ERROR <> 0) 
                        begin
                            raiserror('Failed [%s]', 16, 1, @alterCommand);
                            return 1
                        end

                        set @alterCommand = 'use ' + db_name() + '; ALTER PARTITION FUNCTION [pfTaxDetails] () SPLIT RANGE (' +
                            convert(varchar, @endDate) + ')'
                        exec(@alterCommand);
                        if (@@ERROR <> 0) 
                        begin
                            raiserror('Failed [%s]', 16, 1, @alterCommand);
                            return 1
                        end

                        declare @newPartitionEndDate datetime
                        SELECT @newPartitionEndDate=min(dt_start) FROM t_pc_interval 
                            WHERE id_cycle=@partitionCycle AND dt_start > @partitionEndDate
                            
                        -- Update the partition dates and see if we should stop looping
                        set @partitionStartDate = @partitionEndDate
                        set @partitionEndDate = @newPartitionEndDate
                    end
                    
                    print 'NumPartitionsAdded='
                    print @numPartitionsAdded
                    return @ret
                end
                