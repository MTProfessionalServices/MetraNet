
				declare @tempfoo table (tname varchar(256))
				declare @cursorvar as CURSOR
				declare @i as int
				declare @count as int
				declare @id_template as int
				declare @paramtable as varchar(256)
				declare @tempstr as nvarchar(800)

				set @id_template = %%ID_TEMPLATE%%

				insert into @tempfoo (tname) 
				select name from sysobjects where id in
				(
					select fkeyid from sysforeignkeys where rkeyid = 
						(select id from sysobjects where name = 't_rsched')
				)
				set @cursorvar = CURSOR STATIC FOR SELECT * from @tempfoo
				OPEN @cursorvar
				set @i = 0
				set @count = @@cursor_rows


				while(@i < @count) begin
					FETCH NEXT FROM @cursorvar into @paramtable	
					/* select @paramtable */
					set @tempstr = N'delete from ' + @paramtable + ' where id_sched in (select id_sched from t_rsched where id_pi_template = ' + CAST(@id_template as varchar(256)) + ')'
					/* select @tempstr */
					exec sp_executesql @tempstr
					set @i = @i + 1
				end

				delete from t_pl_map where id_pi_template = @id_template
				delete from t_pi_template where id_template = @id_template
			