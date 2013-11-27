
                -- Create the files and filegroups necessary for partitioning the
                -- t_tax_details table.  Also, generate the partitionFunctionCommand
                -- and the partitionSchemeCommand
                --
                -- @intervalStatusToConsider - Determines if this procedure should
                --  consider open/closed/soft-closed intervals when creating the new
                --  partitions.
                --
                -- @partitionFunctionCommand OUT - String that contains an sql command
                --  to create the partition function e.g.
                --  CREATE PARTITION FUNCTION [testPf](id_usage_interval) AS RANGE RIGHT FOR VALUES (1013252096, 1015283712)
                -- 
                -- @partitionSchemeCommand OUT - String that contains an sql command
                --  to create the partition scheme e.g.
                --  CREATE PARTITION SCHEME [testPs] AS PARTITION [testPf] TO ( [fgIntervalIdLessThan1013252096], 
                --  [fgIntervalId1013252096_1015283712], [PRIMARY])
                -- 
                -- return 0 on success, 1 on failure
                create proc PrepareTaxDetailPartitions
                    @intervalStatusToConsider varchar(20), 
                    @partitionFunctionCommand varchar(500) output, 
                    @partitionSchemeCommand varchar(500) output
                as
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    -- Get minimum interval start date and and maximum interval end date for all
                    -- of the active intervals (interval status is B or O)
                    declare @minIntervalStartDate datetime
                    declare @maxIntervalEndDate datetime
                    select @minIntervalStartDate=min(dt_start), @maxIntervalEndDate=max(dt_end) 
                        from t_usage_interval ui
                        where ui.tx_interval_status like @intervalStatusToConsider

                    -- Now we need to create partitions with the specified cycle (e.g. monthly, yearly)
                    -- that will encompass the minIntervalStartDate and maxIntervalEndDate

                    -- Get the partition cycle from t_usage_server.  The cycle was specified
                    -- during installation.
                    -- e.g. daily, weekly, bi-monthly, monthly, quarterly, yearly
                    declare @partitionCycle int
                    select @partitionCycle = partition_cycle from t_usage_server

                    -- The first partition doesn't really have a start date.  It only has an
                    -- end date.  Assume 19700101 is the beginning of time.
                    declare @partitionStartDate datetime
                    set @partitionStartDate = '19700101'

                    -- Assume t_pc_interval contains a range with the appropriate cycle
                    -- that we can use for the first partition.
                    declare @partitionEndDate datetime
                    SELECT @partitionEndDate=max(dt_start) FROM t_pc_interval 
                        WHERE id_cycle=@partitionCycle AND dt_start <= @minIntervalStartDate

                    set @partitionFunctionCommand = 'CREATE PARTITION FUNCTION pfTaxDetails(int) AS RANGE LEFT FOR VALUES ('

                    set @partitionSchemeCommand = 'CREATE PARTITION SCHEME psTaxDetails as partition pfTaxDetails to ('
                    
                    declare @isFirstTimeInLoop int
                    set @isFirstTimeInLoop = 1;

                    while (1 = 1)
                    begin
                        -- Reformat the partitionEndDate to match the format of an interval_id
                        -- which has the days-since-1970101 in the upper 16 bits.
                        declare @endDateInIntervalFormat int
                        set @endDateInIntervalFormat = DATEDIFF(DAY, '19700101', @partitionEndDate) * 65536

                        if (@isFirstTimeInLoop = 1)
                        begin
                            set @partitionFunctionCommand = @partitionFunctionCommand + convert(varchar, @endDateInIntervalFormat)
                            set @partitionSchemeCommand = @partitionSchemeCommand + '[PRIMARY], '
                            set @isFirstTimeInLoop = 0
                        end
                        else
                        begin
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
                            -- MAXSIZE = 100MB,
                            -- FILEGROWTH = 5MB
                            -- )
                            -- TO FILEGROUP Fg201205
                            exec CreateAndExecuteAddFileCommand 'file', @partitionNameSuffix, @fileGroupName
                            if (@@ERROR <> 0) 
                            begin
                                return 1
                            end

                            -- Append to the existing partitition function command
                            set @partitionFunctionCommand = @partitionFunctionCommand + ', ' + convert(varchar, @endDateInIntervalFormat)

                            -- Append to the existing partitition scheme command
                            set @partitionSchemeCommand = @partitionSchemeCommand + @fileGroupName + ', '
                        end
                            
                        -- Determine the end date of the next partition
                        declare @newPartitionEndDate datetime
                        SELECT @newPartitionEndDate=min(dt_start) FROM t_pc_interval 
                            WHERE id_cycle=@partitionCycle AND dt_start > @partitionEndDate
                            
                        -- Update the partition dates and see if we should stop looping
                        set @partitionStartDate = @partitionEndDate
                        set @partitionEndDate = @newPartitionEndDate
                        
                        if (@partitionStartDate >= @maxIntervalEndDate)
                        begin
                            break
                        end
                    end

                    set @partitionFunctionCommand = @partitionFunctionCommand + ')'

                    set @partitionSchemeCommand = @partitionSchemeCommand + '[PRIMARY])'

                    return 0
                end
                