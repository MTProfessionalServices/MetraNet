DECLARE @alter_table bit, @rename_index bit
DECLARE @backupname varchar(40), @myrename_command nvarchar(200), @my_rename_command2 nvarchar(200)
select @alter_table = 0, @rename_index = 0
BEGIN TRY
  if not exists(select 1 from sys.tables where name = 'MVM_SERVER_CREDENTIALS')
  BEGIN
    PRINT N'CREATING TABLE MVM_SERVER_CREDENTIALS'
	IF EXISTS(select 1 from sys.indexes where name = 'mvm_server_cred_pk')
    BEGIN
      select @backupname = 'MVM_SERVER_CREDENTIALS_'+left(cast(newid() as varchar(50)),10)+'_pk'
      select @my_rename_command2 = N'EXEC sp_rename ''mvm_server_cred_pk'','''+@backupname+''''
      PRINT N'Renaming primary key index mvm_server_cred_pk to ' + @backupname
      exec sp_executesql @my_rename_command2
	END  
    create table [dbo].mvm_server_credentials(
        server_id int not null,
        server_type varchar(400) not null,
        server varchar(400) not null,
        username varchar(4000) null,
        password varchar(4000) null,
        CONSTRAINT mvm_server_cred_pk PRIMARY KEY (server_id)
        )    
  END
  ELSE
  BEGIN
		IF NOT EXISTS(select 1 from sys.columns where name = 'SERVER_TYPE' and object_id = object_id('MVM_SERVER_CREDENTIALS'))
		BEGIN
			PRINT N'MVM_SERVER_CREDENTIALS has no server_type column'
			set @alter_table =1
		END
		IF NOT EXISTS(select 1 from sys.columns where name = 'SERVER_ID' and object_id = object_id('MVM_SERVER_CREDENTIALS'))
		BEGIN
			PRINT N'MVM_SERVER_CREDENTIALS has no server_id column'
			set @alter_table =1
		END
        IF NOT EXISTS(select 1 from sys.indexes i 
        join sys.index_columns ic on i.object_id = ic.object_id and i.index_id = ic.index_id
        join sys.columns c on i.object_id = c.object_id and ic.column_id = c.column_id
        where object_name(i.object_id) = 'mvm_server_credentials' and i.is_primary_key =1 and c.name='server_id')
        BEGIN
          PRINT N'MVM_SERVER_CREDENTIALS primary key on server id column not found'
          set @alter_table=1
        END
	    IF EXISTS(select 1 from sys.indexes where name = 'mvm_server_cred_pk')
		    set @rename_index = 1
        IF (@alter_table = 1)
        BEGIN
           select @backupname = 'MVM_SERVER_CREDENTIALS_'+left(cast(newid() as varchar(50)),10)
           select @myrename_command = N'EXEC sp_rename ''MVM_SERVER_CREDENTIALS'', '''+@backupname+'''' 
           PRINT N'Renaming table MVM_SERVER_CREDENTIALS to ' + @backupname
     	   exec sp_executesql @myrename_command
  		   if (@rename_index = 1)
           BEGIN
	    	 select @backupname = @backupname+'_pk'
	         select @my_rename_command2 = N'EXEC sp_rename ''mvm_server_cred_pk'','''+@backupname+''''
	         PRINT N'Renaming primary key index mvm_server_cred_pk to ' + @backupname
	         exec sp_executesql @my_rename_command2
          END
	      PRINT N'Recreating MVM_SERVER_CREDENTIALS table'
          create table [dbo].mvm_server_credentials(
          server_id int not null,
          server_type varchar(400) not null,
          server varchar(400) not null,
          username varchar(4000) null,
          password varchar(4000) null,
          CONSTRAINT mvm_server_cred_pk PRIMARY KEY (server_id)
          )    
       END
     ELSE
       PRINT N'MVM_SERVER_CREDENTIALS table found with server_type and server_id columns and primary key on server_id'  
   END
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH;
