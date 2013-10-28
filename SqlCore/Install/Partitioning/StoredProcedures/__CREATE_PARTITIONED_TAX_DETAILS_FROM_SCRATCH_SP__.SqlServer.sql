
                -- t_tax_details doesn't exist yet, so determine the SQL necessary to create
                -- this table in partitioned way, and execute it
                -- 
                -- return 0 on success, 1 on failure
                create proc CreatePartitionedTaxDetailsFromScratch
                as
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    -- Only consider open and soft-closed intervals
                    declare @intervalStatus varchar(20)
                    set @intervalstatus = '[BO]'

                    -- Create variables to hold the commands that we will generate.
                    -- The commands will look like this when they are run:
                    --
                    -- CREATE PARTITION FUNCTION [testPf](id_usage_interval) AS RANGE RIGHT FOR VALUES (1013252096, 1015283712)
                    -- 
                    -- CREATE PARTITION SCHEME [testPs] AS PARTITION [testPf] TO ( [fgIntervalIdLessThan1013252096], 
                    -- [fgIntervalId1013252096_1015283712], [PRIMARY])
                    --
                    declare @partitionFunctionCommand varchar(MAX)
                    declare @partitionSchemeCommand varchar(MAX)

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

                    -- Now create the partitioned t_tax_details table
                    declare @taxDetailRowDefinitions varchar(1000)
                    exec GetTaxDetailRowDefinitions @taxDetailRowDefinitions out
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed GetTaxDetailRowDefinitions', 16, 1);
                        return 1
                    end

                    declare @createTableCommand varchar(1000)
                    set @createTableCommand = 'CREATE TABLE [t_tax_details](' +
                        @taxDetailRowDefinitions +
                        ') ON psTaxDetails(id_usage_interval)';
                    exec(@createTableCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @createTableCommand);
                        return 1
                    end

                    CREATE UNIQUE CLUSTERED INDEX TaxDetailIndex ON t_tax_details
                    (
                        id_usage_interval ASC,
                        id_acc ASC,
                        id_tax_detail ASC
                    ) 
                    ON psTaxDetails(id_usage_interval)

                    -- successfully created a partitioned t_tax_details table
                    return 0
                end
                