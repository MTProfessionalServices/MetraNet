
                -- Generate a string to use as the suffix on the file group name and the file name
                -- e.g. IdInterval_1013252096_1015283712
                --
                create proc GeneratePartitionNameSuffix
                    @partitionStartDate datetime, 
                    @partitionEndDate datetime, 
                    @partitionNameSuffix  varchar(500) output
                as
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    -- The upper 16 bits of id_usage_interval contain Days since the epoch (19700101)
                    -- The lower 16 bits contain the interval cycle id
                    declare @startDate int
                    set @startDate = DATEDIFF(DAY, '19700101', @partitionStartDate) * 65536
                    declare @endDate int
                    set @endDate = (DATEDIFF(DAY, '19700101', @partitionEndDate) * 65536)

                    set @partitionNameSuffix = 'IdInterval_' + convert(varchar, @startDate) + '_' +
                        convert(varchar, @endDate)

                    return @ret
                end
                