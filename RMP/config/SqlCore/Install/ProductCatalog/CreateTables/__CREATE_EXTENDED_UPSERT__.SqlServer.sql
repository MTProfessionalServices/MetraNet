
			create proc ExtendedUpsert(@table_name as varchar(100),
											@update_list as varchar(8000),
											@insert_list as varchar(8000),
											@clist as varchar(8000),
											@id_prop as int,
											@status int output)
			as
			declare @rowcount as int
			exec('update ' + @table_name + ' set ' + 
			@update_list + ' where ' + @table_name + '.id_prop = ' + @id_prop)
			set @rowcount = @@rowcount
			set @status = @@error
			if @rowcount = 0 begin
				exec('insert into ' + @table_name + ' (id_prop,' + @clist + ') values( ' + @id_prop + ',' + @insert_list + ')')
				set @status = @@error
			end
		