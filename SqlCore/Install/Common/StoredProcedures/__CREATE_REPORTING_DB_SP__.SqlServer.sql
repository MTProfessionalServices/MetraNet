
	   create procedure CreateReportingDB (
                    @strDBName nvarchar(100),
                    @strNetmeterDBName nvarchar(100),
                    @strDataLogFilePath nvarchar(255),
                    @dbSize integer,
					@return_code integer output
                   )
as
  set @return_code = 0
  declare @strDataFileName    nvarchar(255);
  declare @strLogFileName     nvarchar(255);
  declare @strDBCreateQuery   nvarchar(2000);
  declare @strAddDbToBackupQuery nvarchar(2000);
  declare @strProcess         nvarchar(100)
  declare @nSQLRetCode        INT

  declare @bDebug tinyint
  set @bDebug = 1

  declare @strsize nvarchar(5);
  set @strsize = CAST(@dbSize AS nvarchar(5))
  set  @strDataFileName = @strDataLogFilePath + '\' + @strDBName + '_Data';
  set  @strLogFileName =  @strDataLogFilePath + '\' + @strDBName + '_Log';


  set @strDBCreateQuery = 'if not exists(select * from sys.databases where name = N''' + @strDBName + ''')
    CREATE DATABASE [' + @strDBName + ']  ON
                           (
                                    NAME = N''' + @strDBName + '_Data' + ''',
                                FILENAME = N''' + @strDataFileName + '.MDF' + ''' ,
                                    SIZE = ' + @strsize + ',
                              FILEGROWTH = 20%
                            )
                            LOG ON
                            (
                                    NAME = N''' + @strDBName + '_Log' + ''',
                                FILENAME = N''' + @strLogFileName + '.LDF' + ''' ,
                                    SIZE = ' + @strsize + ',
                              FILEGROWTH = 10%
                            )'
  set @strAddDbToBackupQuery = 'insert into ' + @strNetmeterDBName + '..t_ReportingDBLog(NameOfReportingDB, doBackup)
							    Values(''' + @strDBName + ''', ''Y'')';

  if ( @bDebug = 1 )
      print 'About to execute create DB Query : ' + @strDBCreateQuery;

  exec sp_executesql @strDBCreateQuery
  select @nSQLRetCode = @@ERROR
  if ( @nSQLRetCode <> 0 )
  begin
    set @strProcess = object_name(@@procid)
    print 'An error occured while creating the database. Procedure (' + @strProcess + ')';
    set @return_code = -1
    return -1
  end
  -- set the simple log option for database.
  SET @strDBCreateQuery = 'Alter Database ' + @strDBName + ' SET RECOVERY SIMPLE';
  exec sp_executesql @strDBCreateQuery
  select @nSQLRetCode = @@ERROR
  if ( @nSQLRetCode <> 0 )
  begin
    set @strProcess = object_name(@@procid)
    print 'An error occured while setting the recovery option to Bulk-Logged to the created database. Procedure (' + @strProcess + ')';
    set @return_code = -1
    return -1
  end

  if ( @bDebug = 1 )
      print 'About to execute add DB to backup table Query : ' + @strAddDBToBackupQuery;

  exec sp_executesql @strAddDBToBackupQuery
  BEGIN TRY
    exec sp_executesql @strAddDBToBackupQuery
  END TRY
  BEGIN CATCH
   	  declare
   	       @ErrorMessage varchar(2048),
   	       @ErrorSeverity INT
   	  select
   	       @ErrorMessage = ERROR_MESSAGE(),
   	       @ErrorSeverity = ERROR_SEVERITY()
   	  if (patindex('%pk_t_ReportingDBLog%', @ErrorMessage) > 0)
   	    BEGIN
   	         PRINT @ErrorMessage
   	      set @return_code = 0
   	      SET @nSQLRetCode = 0
   	    end
   	  ELSE
        begin
          SET @nSQLRetCode = ERROR_NUMBER()
   	      raiserror(@ErrorMessage, @ErrorSeverity, 1)
 	    end
  END CATCH
  -- select @nSQLRetCode = @@ERROR
  if ( @nSQLRetCode <> 0 )
  begin
    set @strProcess = object_name(@@procid)
    print 'An error occured while adding database to t_ReportingDBLog table. Procedure (' + @strProcess + ')';
    set @return_code = -1
    return -1
  end

  return 0
			