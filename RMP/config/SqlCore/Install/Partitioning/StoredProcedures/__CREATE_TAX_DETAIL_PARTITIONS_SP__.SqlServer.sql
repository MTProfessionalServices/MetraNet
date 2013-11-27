
                -- Description: Create the partitions for the t_tax_details table
                -- Algorithm:
                --      If (t_tax_details doesn't exist and isPartitioningEnabled is true)
                --      {
                --          create file groups
                --          create files
                --          create partition function
                --          create partition scheme
                --          create t_tax_detail table
                --      }
                --      else if (t_tax_details doesn't exist and isPartitioningEnabled is false)
                --      {
                --          create t_tax_detail table
                --      }
                --      else if (t_tax_details exists and isPartitioningEnabled is false)
                --      {
                --          nothing to do
                --      }
                --      else if (t_tax_details exists, isPartitioningEnabled is true, but t_tax_details is not partitioned)
                --      {
                --          create file groups
                --          create files
                --          create partition function
                --          create partition scheme
                --          create partioned index
                --      }
                --      else // t_tax_details exists and is already partitioned
                --      {
                --          create file groups
                --          create files
                --          alter partition function
                --          alter partition scheme
                --      }
                --  
                --      Information about the partitions can be obtained
                --      from the view v_partition_info via "select * from v_partition_info"
                -- 
                create proc CreateTaxDetailPartitions
                as
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    -- Set environment for this session
                    set nocount on

                    -- Abort if system isn't enabled for partitioning
                    if dbo.IsSystemPartitioned() = 0
                    begin
                        if OBJECT_ID('t_tax_details') IS NULL
                        begin
                            -- Partitioning disabled, and t_tax_details table doesn't exist, so create it
                            print 'CreateUnpartitionedTaxDetailsTable'
                            exec CreateUnpartitionedTaxDetailsTable
                            if (@@ERROR <> 0) 
                            begin
                                raiserror('CreateUnpartitionedTaxDetailsTable failed', 16, 1);
                                set @ret = 1
                            end
                        end
                        else
                        begin
                            print 'unpartitioned t_tax_details already exists, nothing to do'
                        end
                    end
                    else if OBJECT_ID('t_tax_details') IS NULL
                    begin
                        -- Create partitioned t_tax_details from scratch
                        -- that will handle the existing open intervals
                        print 'CreatePartitionedTaxDetailsFromScratch'
                        exec CreatePartitionedTaxDetailsFromScratch
                        if (@@ERROR <> 0) 
                        begin
                            raiserror('CreatePartitionedTaxDetailsFromScratch failed', 16, 1);
                            set @ret = 1
                        end
                    end
                    else
                    begin
                        -- Create a cursor capable of looping on the 
                        -- existing partitions of the t_tax_details table.
                        declare partitionInfoCursor CURSOR FOR SELECT c_partition_number FROM v_partition_info vpi WHERE vpi.c_object_name='t_tax_details'
                        open partitionInfoCursor

                        if CURSOR_STATUS('global', 'partitionInfoCursor') = 0
                        begin
                            -- t_tax_details exists, but does not have any partitions
                            print 'PartitionExistingTaxDetailsTable'
                            exec PartitionExistingTaxDetailsTable
                            if (@@ERROR <> 0) 
                            begin
                                raiserror('PartitionExistingTaxDetailsTable failed', 16, 1);
                                set @ret = 1
                            end
                        end
                        else
                        begin
                            -- t_tax_details exists and is already partitioned
                            -- Add new partitions if necessary
                            print 'AddPartitionsToTaxDetailsTable'
                            exec AddPartitionsToTaxDetailsTable
                            if (@@ERROR <> 0) 
                            begin
                                raiserror('AddPartitionsToTaxDetailsTable failed', 16, 1);
                                set @ret = 1
                            end
                        end
                        close partitionInfoCursor
                        deallocate partitionInfoCursor
                    end

                    return @ret
                end
                