
	Create  procedure Abandon @rerun_table_name nvarchar(30),  @id_rerun int, @return_code int OUTPUT
	as
	Begin
		declare @sql nvarchar(1000)
		set @sql = N'drop table ' + @rerun_table_name
		EXEC sp_executesql @sql

		declare @source_table_name nvarchar(100)
		set @source_table_name = N't_source_rerun_session_' + cast(@id_rerun AS nvarchar(40))
		set @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N''' + @source_table_name + N''') 
			and OBJECTPROPERTY(id, N''IsUserTable'') = 1) DROP TABLE ' + @source_table_name

      		EXEC sp_executesql @sql

		declare @UIDTableName nvarchar(100)
      		set @UIDTableName = N't_UIDList_' + cast(@id_rerun AS nvarchar(40))
      		set @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N''' + @UIDTableName + N''') 
			and OBJECTPROPERTY(id, N''IsUserTable'') = 1) DROP TABLE ' + @UIDTableName

    		EXEC sp_executesql @sql   

      		set @return_code = 0

	End
    