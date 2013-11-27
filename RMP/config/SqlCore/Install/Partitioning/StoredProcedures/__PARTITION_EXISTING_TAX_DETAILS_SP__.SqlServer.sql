
                -- t_tax_details exists, but does not have any partitions.
                -- This procedure creates the appropriate file groups, files,
                -- partitionFunction, partitionScheme,
                -- and then partitions an existing t_tax_details table
                create proc PartitionExistingTaxDetailsTable
                as
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    -- Only consider open and soft-closed intervals
                    declare @intervalStatus varchar(20)
                    set @intervalstatus = '[BO]'

                    -- Create variables to hold the createPartitionCommand/createSchemeCommand
                    declare @partitionFunctionCommand varchar(500)
                    declare @partitionSchemeCommand varchar(500)

                    exec PrepareTaxDetailPartitions @intervalStatus, @partitionFunctionCommand output, @partitionSchemeCommand output
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [PrepareTaxDetailPartitions]', 16, 1, @partitionFunctionCommand);
                        return 1
                    end

                    -- The partitionFunctionCommand is now complete, so execute it
                    exec(@partitionFunctionCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @partitionFunctionCommand);
                        return 1
                    end

                    -- The partitionSchemeCommand is now complete, so execute it
                    exec(@partitionSchemeCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @partitionSchemeCommand);
                        return 1
                    end

                    -- We already have the files, filegroups, partitionFunction, partitionScheme,
                    -- and an existing unpartitioned t_tax_details table.  So, re-create the TaxDetailIndex
                    -- so that the table will be partitioned.
                    CREATE UNIQUE CLUSTERED INDEX TaxDetailIndex ON t_tax_details
                    (
                        id_usage_interval ASC,
                        id_acc ASC,
                        id_tax_detail ASC
                    ) 
                    WITH (DROP_EXISTING = ON)
                    ON psTaxDetails(id_usage_interval)

                    -- successfully created a partitioned t_tax_details table
                    return 0
                end
                