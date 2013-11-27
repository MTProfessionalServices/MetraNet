
                -- Copy the contents of the oldest partition to the specified file
                -- and update the partition boundaries/filegroups/files.
                --
                -- @backupFile The file where the rows from the oldest partition will be stored
                --
                create proc ArchiveOldestTaxDetailPartition
                    @backupFile varchar(500)
                    AS
                begin
                    -- Make sure there are enough partitions so that we can delete one
                    declare @numPartitions int
                    select @numPartitions=Count(*) from v_partition_info

                    if (@numPartitions <= 3)
                    begin
                        raiserror('You must have more than 3 partitions to archive the oldest', 16, 1);
                        return 1
                    end

                    -- Create a variable to hold the left-most boundary
                    DECLARE @firstBoundaryValue int
                    SELECT @firstBoundaryValue=convert(int,c_boundary_value)
                          FROM v_partition_info pi1 WHERE pi1.c_partition_number=1
                          
                    -- Create a variable to hold the boundary just to the right of the left-most boundary
                    DECLARE @secondBoundaryValue int
                    DECLARE @fileGroupName VARCHAR(1000)
                    SELECT @fileGroupName=pi1.c_filegroup_name, @secondBoundaryValue=convert(int,c_boundary_value)
                          FROM v_partition_info pi1 WHERE pi1.c_partition_number=2

                    -- Create a temporary table to hold the rows from the oldest partition
                    declare @taxDetailRowDefinitions varchar(1000)
                    exec GetTaxDetailRowDefinitions @taxDetailRowDefinitions out
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed GetTaxDetailRowDefinitions', 16, 1);
                        return 1
                    end

                    -- Create the temporary table to hold the rows we will archive
                    declare @createTableCommand varchar(1000)
                    set @createTableCommand = 'CREATE TABLE [t_temp_tax_details](' +
                        @taxDetailRowDefinitions +
                        ') ON ' + @fileGroupName;
                    exec(@createTableCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @createTableCommand);
                        return 1
                    end

                    -- Create an index on this table
                    CREATE UNIQUE CLUSTERED INDEX TempTaxDetailIndex ON t_temp_tax_details
                    (
                        id_usage_interval ASC,
                        id_acc ASC,
                        id_tax_detail ASC
                    ) 

                    -- Now move the contents of t_tax_details that reside in the oldest partition 
                    -- to the temporary table in the same filegroup
                    declare @moveCommand varchar(1000)
                    set @moveCommand = 'ALTER TABLE t_tax_details SWITCH PARTITION ' +
                        convert(varchar, 2)  + ' TO t_temp_tax_details';
                    exec(@moveCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @moveCommand);
                        return 1
                    end

                    -- Backup the table using BCP to the specified file
                    declare @backupCommand varchar(1000)
                    SET @backupCommand = 'bcp.exe ' +
                        db_name() + '.dbo.t_temp_tax_details out ' + @backupFile + ' -c -T';
                    exec master.dbo.xp_cmdshell @backupCommand;
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @backupCommand);
                        return 1
                    end

                    -- Now we can remove the temporary table
                    DROP TABLE t_temp_tax_details
                    
                    -- Now we can update the partition function e.g.
                    -- ALTER PARTITION FUNCTION pfTaxDetails() MERGE RANGE (<boundaryValue>);
                    declare @updatePartitionFunctionCommand varchar(1000)
                    set @updatePartitionFunctionCommand = 'alter partition function pfTaxDetails() merge range (' + 
                        convert(varchar, @secondBoundaryValue) + ')';
                    exec(@updatePartitionFunctionCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @updatePartitionFunctionCommand);
                        return 1
                    end

                    -- Now we can eliminate the specified file group from the partition function
                    declare @removeFileGroupCommand varchar(1000)
                    DECLARE @fileAssociatedWithFileGroup VARCHAR(1000)
                    SET @fileAssociatedWithFileGroup = 'file' + SUBSTRING(@fileGroupName, 3, 9999);
                    set @removeFileGroupCommand = 
                        'alter database ' + db_name() + ' remove file ' + @fileAssociatedWithFileGroup + ';' +
                        'alter database ' + db_name() + ' remove filegroup ' + @fileGroupName;
                    exec(@removeFileGroupCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @removeFileGroupCommand);
                        return 1
                    end

                    -- Now we need to move the left most partition boundary to the right
                    set @updatePartitionFunctionCommand = 'alter partition scheme psTaxDetails next used [primary];' +
                        'alter partition function pfTaxDetails() split range (' + convert(varchar, @secondBoundaryValue) + ');' + 
                        'alter partition function pfTaxDetails() merge range (' + convert(varchar, @firstBoundaryValue) + ');';
                    exec(@updatePartitionFunctionCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @updatePartitionFunctionCommand);
                        return 1
                    end
                end
                