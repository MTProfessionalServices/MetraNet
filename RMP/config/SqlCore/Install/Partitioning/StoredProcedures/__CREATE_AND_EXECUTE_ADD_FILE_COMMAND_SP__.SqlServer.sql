
                -- Using the passed in arguments, generate an SQL statement that
                -- looks like the following and executes it:
                --      ALTER DATABASE NetMeter ADD FILE
                --      ( 
                --      NAME = 'File201205.ndf',
                --      FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\testFile201205.ndf',
                --      SIZE = 5MB,             // This is the initial size 
                --      MAXSIZE = UNLIMITED,    // Let it grow this big
                --      FILEGROWTH = 5MB        // Grow by this much when file needs to grow
                --      )
                --      TO FILEGROUP Fg201205
                --
                -- returns 0 on success, 1 on failure
                create proc CreateAndExecuteAddFileCommand 
                    @filePrefix varchar(500),
                    @fileSuffix varchar(500),
                    @fileGroupName varchar(500)
                as
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    -- The storage path for the new file is obtained from t_partition_storage
                    -- This method uses a round-robin strategy to figure out which storage
                    -- path should be used.
                    declare @storagePath varchar(500)
                    exec GetNextStoragePath @storagePath out
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed GetNextStoragePath', 16, 1);
                        return 1
                    end
                    set @storagePath = rtrim(@storagePath)

                    declare @fileName varchar(500)
                    set @fileName = @filePrefix + @fileSuffix

                    declare @fullPathFileName varchar(1000)
                    set @fullPathFileName = @storagePath + '\' + @fileName

                    declare @addFileCommand varchar(1000)
                    set @addFileCommand = 'alter database ' + db_name() + ' add file' +
                        '(' +
                        'NAME = ''' + @fileName + ''', ' +
                        'FILENAME = N''' + @fullPathFileName + ''', ' +
                        'SIZE = 5MB, ' +
                        'MAXSIZE = UNLIMITED, ' +
                        'FILEGROWTH = 5MB' +
                        ')' +
                        'TO FILEGROUP ' + @fileGroupName

                    exec(@addFileCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @addFileCommand);
                        return 1
                    end

                    return @ret
                end
                