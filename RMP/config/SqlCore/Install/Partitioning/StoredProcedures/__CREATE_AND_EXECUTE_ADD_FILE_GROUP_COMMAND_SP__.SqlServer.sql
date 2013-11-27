
                -- Using the passed in arguments, generate an SQL statement that
                -- looks like the following and executes it:
                --      ALTER DATABASE NetMeter ADD FILEGROUP fgTaxDetail201205
                --
                -- returns 0 on success, 1 on failure
                create proc CreateAndExecuteAddFileGroupCommand
                    @fileGroupPrefix varchar(500),
                    @fileGroupSuffix varchar(500),
                    @fileGroupName varchar(500) output
                    AS
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    set @fileGroupName = @fileGroupPrefix + @fileGroupSuffix

                    declare @addFileGroupCommand varchar(1000)
                    set @addFileGroupCommand = 'alter database ' + db_name() + ' add filegroup ' + @fileGroupName

                    exec(@addFileGroupCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @addFileGroupCommand);
                        return 1
                    end

                    return @ret
                end
                