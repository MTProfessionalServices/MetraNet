
    Create   Procedure DeleteSourceData(@rerun_table_name nvarchar(30), @metradate nvarchar(30)) as
    begin
    declare @sql nvarchar(4000)

	  -- values we get from the cursor
	  declare @tablename varchar(255)
	  declare @id_svc int

	  -- delete from the service tables.
	  set @sql = N'DECLARE tablename_cursor CURSOR FOR
	    select rr.id_svc, svc.nm_table_name from 
		  t_enum_data ed
		  inner join ' + @rerun_table_name + N' rr 
		  on rr.id_svc = ed.id_enum_data
		  inner join t_service_def_log svc
		  on svc.nm_service_def = ed.nm_enum_data
		  where (rr.tx_state = ''B'' OR
			rr.tx_state = ''NA'')
		  group by rr.id_svc, svc.nm_table_name'


	  EXEC sp_executesql @sql

	  OPEN tablename_cursor
	  FETCH NEXT FROM tablename_cursor into @id_svc, @tablename
	  WHILE @@FETCH_STATUS = 0
	  BEGIN
	   set @sql = N'DELETE from ' + @tablename
			+ N' where id_source_sess in (select id_source_sess from ' + @rerun_table_name +
			N' where id_svc = ' + CAST(@id_svc AS VARCHAR(10))
			+ N' and (tx_state = ''B'' or tx_state = ''NA''))'

	   exec (@sql)
	   FETCH NEXT FROM tablename_cursor into @id_svc, @tablename
	  END
	  CLOSE tablename_cursor
	  DEALLOCATE tablename_cursor

	  -- update t_session_state
	  set @sql = N'update t_session_state
		  set dt_end =  ''' + @metradate + N'''
		  from ' + @rerun_table_name + N' rr
		  inner join t_session_state ss
		  on rr.id_source_sess = ss.id_sess
		  where ss.dt_end = dbo.MTMaxDate()
		  and rr.tx_state = ''B'' '

	  EXEC sp_executesql @sql

	  set @sql = N'INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state) 
		    SELECT rr.id_source_sess, ''' + @metradate + N''', dbo.MTMaxDate(), ''D''
		    from ' + @rerun_table_name + N' rr
		    where rr.tx_state = ''B'' '

	  EXEC sp_executesql @sql

	-- update t_message for pending and suspended transactions
	-- for pending, the dt_assigned and dt_completed are
	-- set to MTMAXDate, for suspended, the dt_completed 
	-- to MTMaxDate

	set @sql = N'update t_message
			set dt_assigned = dbo.MTMaxDate() 
			where id_message in (
			select ss.id_message from ' + @rerun_table_name + N' rr
			inner join t_session sess WITH (READCOMMITTED)
			on sess.id_source_sess = rr.id_source_sess
			inner join t_session_set ss WITH (READCOMMITTED)
			on sess.id_ss = ss.id_ss
			inner join t_message msg WITH (READCOMMITTED)
			on msg.id_message = ss.id_message
			where rr.tx_state = ''NA'')
			and dt_assigned is null'

	EXEC sp_executesql @sql
	set @sql = N'update t_message
			set dt_completed = dbo.MTMaxDate()
			where id_message in (
			select ss.id_message from ' + @rerun_table_name + N' rr
			inner join t_session sess WITH (READCOMMITTED)
			on sess.id_source_sess = rr.id_source_sess
			inner join t_session_set ss WITH (READCOMMITTED)
			on sess.id_ss = ss.id_ss
			inner join t_message msg WITH (READCOMMITTED)
			on msg.id_message = ss.id_message
			where rr.tx_state = ''NA'')
			and dt_completed is null'

	EXEC sp_executesql @sql

 end


    