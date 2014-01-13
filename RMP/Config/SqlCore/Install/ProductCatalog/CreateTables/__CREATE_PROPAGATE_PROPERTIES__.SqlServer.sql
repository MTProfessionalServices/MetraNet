
			create proc PropagateProperties(@table_name as varchar(100),
											@update_list as varchar(8000),
											@insert_list as varchar(8000),
											@clist as varchar(8000),
											@id_pi_template as int)

			as
			declare @CursorVar CURSOR
			declare @count as int
			declare @i as int
			declare @idInst as int
			declare @status as int
			set @status = 0
			set @i = 0
			set @CursorVar = CURSOR STATIC
				FOR select id_pi_instance from t_pl_map
						where id_pi_template = @id_pi_template and id_paramtable is null
			OPEN @CursorVar
			select @count = @@cursor_rows
			while @i < @count begin
				FETCH NEXT FROM @CursorVar into @idInst
				set @i = (select @i + 1)
				exec ExtendedUpsert @table_name, @update_list, @insert_list, @clist, @idInst, @status OUTPUT
				if (@status <> 0) begin
      				raiserror('Cannot insert data into [%s], error %d.', 16, 1, @table_name, @status)
				end
			end
			CLOSE @CursorVar
			DEALLOCATE @CursorVar
		