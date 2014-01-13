
  Create PROCEDURE Analyze (@table_name nvarchar(30))
    as
    begin
	  declare @rows_changed int
	  declare @query nvarchar(4000)
	  declare @svctablename nvarchar(255)
	  declare @id_svc nvarchar(10)
     
	  -- mark the successful rows as analyzed.
		if exists (select 1 from t_usage_server where b_partitioning_enabled = 'N')
		begin
			set @query = N'update ' + @table_name +
					N' set tx_state = ''A''
					from ' + @table_name + N' rr
					inner join t_acc_usage acc
					on rr.id_sess = acc.id_sess
					and acc.id_usage_interval = rr.id_interval
					where tx_state = ''I'''
		end
		else
		begin
				set @query = N'update ' + @table_name +
					N' set tx_state = ''A''
					from ' + @table_name + N' rr
					inner join t_uk_acc_usage_tx_uid acc
					on rr.id_source_sess = acc.tx_uid
					where tx_state = ''I'''
		end
	  EXEC sp_executesql @query
	  
	  -- set the id_parent_source_sess correctly for the children already 
	  -- identified by now (successful only)
	 
	  set @query = N'update ' + @table_name +
		  N' set id_parent_source_sess = acc.tx_uid
		  from ' + @table_name + N' rr
		  inner join t_acc_usage acc
		  on rr.id_parent_sess = acc.id_sess
		  and acc.id_usage_interval = rr.id_interval
		  where acc.id_parent_sess is null
		  and rr.id_parent_source_sess is null
		  and rr.tx_state = ''A'''
    EXEC sp_executesql @query
    
	  -- just so the loop will run the first time
	  set @rows_changed = 1

		-- find parents for successful sessions
		set @query = N'
		insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
		  select distinct 
			auparents.tx_UID,	-- id_source_sess
			auparents.tx_batch,	-- tx_batch
			auparents.id_sess,	-- id_sess
			auparents.id_parent_sess,	-- id_parent
			null,				-- TODO: root
			auparents.id_usage_interval,	-- id_interval
			auparents.id_view,		-- id_view
			case aui.tx_status when ''H'' then ''C'' else ''A'' end, -- c_state
			auparents.id_svc,		-- id_svc
			NULL, -- id_parent_source_sess
			auparents.id_acc,
			auparents.amount,
			auparents.am_currency
		  from t_acc_usage auchild
		  inner join ' + @table_name + N' rr on auchild.id_sess = rr.id_sess
  		  and auchild.id_usage_interval =rr.id_interval
		  inner join t_acc_usage auparents on auparents.id_sess = auchild.id_parent_sess
		  and auparents.id_usage_interval =auchild.id_usage_interval
		  inner join t_acc_usage_interval aui on auparents.id_usage_interval = aui.id_usage_interval
        and auparents.id_acc = aui.id_acc
		  where not exists (select * from ' + @table_name + N' rr1 where rr1.id_sess = auparents.id_sess and auparents.id_usage_interval =rr1.id_interval)'
		EXEC sp_executesql @query

		-- find children for successful sessions
		set @query = N'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, 
				root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
		  select
			au.tx_UID,	-- id_source_sess
			au.tx_batch,	-- tx_batch
			au.id_sess,	-- id_sess
			au.id_parent_sess,	-- id_parent
			null,			-- TODO: root
			au.id_usage_interval,	-- id_interval
			au.id_view,		-- id_view
			case aui.tx_status when ''H'' then ''C'' else ''A'' end,			-- tx_state
			au.id_svc,	-- id_svc
			rr.id_source_sess, -- id_parent_source_sess
			au.id_acc,
			au.amount,
			au.am_currency
			from t_acc_usage au
			inner join ' + @table_name + N' rr on au.id_parent_sess = rr.id_sess
			and au.id_usage_interval = rr.id_interval
			inner join t_acc_usage_interval aui on au.id_usage_interval = aui.id_usage_interval
         and au.id_acc = aui.id_acc
			where not exists (select 1 from ' + @table_name + N' rr1 where rr1.id_sess = au.id_sess
			and rr1.id_interval = au.id_usage_interval)'
		EXEC sp_executesql @query

	 set @rows_changed = 1
	 -- complete the compound for failure cases.  In t_failed_transaction, you will have only the failed
	 -- portion of the failed transaction.
	 while (@rows_changed > 0)
	 begin
		set @rows_changed = 0
		-- find children for failed parent sessions
		-- find tables where children may live.
	  create table #tmpcursor1 (nm_table_name nvarchar(255), id_enum_data int)
	  set @query = N'insert into #tmpcursor1 (nm_table_name, id_enum_data)
			select distinct slog.nm_table_name, ed.id_enum_data
			from ' + @table_name + N'  rr
			inner join t_failed_transaction ft WITH (READCOMMITTED)
			on (rr.id_source_sess = ft.tx_failureCompoundID)
			inner join t_session_set ss WITH (READCOMMITTED)
			on ss.id_ss = ft.id_sch_ss
			inner join t_session_set childss WITH (READCOMMITTED)
			on ss.id_message = childss.id_message
			inner join t_enum_data ed
			on ed.id_enum_data = childss.id_svc
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_parent_source_sess is null and tx_state = ''E''
			and childss.b_root = ''0'''
	  EXEC sp_executesql @query
		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor1
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @svctablename
			set @query = 'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			select 
			conn.id_source_sess,	-- id_source_sess
			conn.c__CollectionID,	-- tx_batch
			NULL,	-- id_sess
			NULL,	-- id_parent_sess
			NULL,			-- TODO: root
			NULL,	-- id_interval
			NULL,		-- id_view
			''E'',			-- tx_state
			'+ @id_svc + N' , 	-- id_svc
			conn.id_parent_source_sess,
			null, -- id_payer
			null, -- amount
			null -- currency
			from ' + @table_name + N' rr
			inner join ' + @svctablename + N' conn WITH (READCOMMITTED)
			on rr.id_source_sess = conn.id_parent_source_sess
			where rr.id_parent_source_sess is null and tx_state = ''E''
			and not exists (select * from ' + @table_name + N' where ' +  @table_name + '.id_source_sess = conn.id_source_sess)'
			EXEC sp_executesql @query
			set @rows_changed = @rows_changed + @@ROWCOUNT
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
    drop table #tmpcursor1
    		-- find parents for failed children sessions
		-- this query gives us all the svc tables in which the parents may live
	  create table #tmpcursor2 (nm_table_name nvarchar(255), id_enum_data int)
	  set @query =  N'insert into #tmpcursor2(nm_table_name, id_enum_data)
			select distinct slog.nm_table_name, cast(ed.id_enum_data as nvarchar(10))
			from ' + @table_name + N' rr
			inner join t_failed_transaction ft WITH (READCOMMITTED)
			on rr.id_source_sess = ft.tx_failureID
			inner join t_session_set ss WITH (READCOMMITTED)
			on ss.id_ss = ft.id_sch_ss
			inner join t_session_set parentss WITH (READCOMMITTED)
			on ss.id_message = parentss.id_message
			inner join t_enum_data ed
			on ed.id_enum_data = parentss.id_svc
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_parent_source_sess is not null
			and tx_state = ''E''
			and ss.id_svc <> parentss.id_svc
			and parentss.b_root = ''1'''
	  EXEC sp_executesql @query
 		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor2
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @svctablename
			set @query = 'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			select 
			call.id_source_sess,	-- id_source_sess
			call.c__CollectionID,	-- tx_batch
			NULL,	-- id_sess
			NULL,	-- id_parent_sess
			NULL,			-- TODO: root
			NULL,	-- id_interval
			NULL,		-- id_view
			''E'',			-- tx_state 
			'+ @id_svc + N' , 	-- id_svc
			call.id_parent_source_sess,
			null, -- id_payer
		  null, -- amount
		  null  -- currency
			from ' + @table_name + N' rr
			inner join ' + @svctablename + N' call WITH (READCOMMITTED)
			on rr.id_parent_source_sess = call.id_source_sess
			where rr.id_parent_source_sess is not null and tx_state = ''E''
			and not exists (select * from ' + @table_name + N' where ' +  @table_name + '.id_source_sess = call.id_source_sess)'
			EXEC sp_executesql @query
			set @rows_changed = @rows_changed + @@ROWCOUNT
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
    DROP TABLE #tmpcursor2
	 end
	-- handle suspended and pending transactions.  We know we will have identified
	-- all suspended and pending parents.  Only children need to be looked at.
	-- following query tells us which tables to look for the children
	-- changing the cursor query.. for whatever reason,it takes too long, even when there are 
	-- no suspended transactions (CR: 13059)
	create table #tmpcursor3 (nm_table_name nvarchar(255), id_enum_data int)
	set @query =  N'insert into #tmpcursor3(nm_table_name, id_enum_data)
			select distinct slog.nm_table_name , cast(ss2.id_svc as nvarchar(10))
			from t_session_set ss2 WITH (READCOMMITTED)
			inner join t_enum_data ed
			on ss2.id_svc = ed.id_enum_data
			inner join t_service_def_log slog
			on ed.nm_enum_data = slog.nm_service_def
			where id_message in (
			select ss.id_message from '+ @table_name + N' rr
			inner join t_session sess WITH (READCOMMITTED)
			on sess.id_source_sess = rr.id_source_sess
			inner join t_session_set ss WITH (READCOMMITTED)
			on sess.id_ss = ss.id_ss
			inner join t_message msg WITH (READCOMMITTED)
			on msg.id_message = ss.id_message
			where rr.tx_state = ''NC'')
			and ss2.b_root = ''0'''
		EXEC sp_executesql @query
		DECLARE tablename_cursor CURSOR FOR select nm_table_name, id_enum_data from #tmpcursor3
		OPEN tablename_cursor
		FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @query = N'insert into ' + @table_name + N' (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
				select svc.id_source_sess, null, 
				null, null, null, null, null, ''NA'', '
				+ cast(@id_svc as nvarchar(10)) + N' , rr.id_source_sess, null, null, null
				from ' + @table_name + N' rr
				inner join ' + @svctablename + N' svc WITH (READCOMMITTED)
				on rr.id_source_sess = svc.id_parent_source_sess
				where rr.tx_state = ''NC''
				and svc.id_source_sess not in (select id_source_sess from ' + @table_name +')'
			EXEC sp_executesql @query
			FETCH NEXT FROM tablename_cursor into @svctablename, @id_svc
		END
		CLOSE tablename_cursor
		DEALLOCATE tablename_cursor
		set @query = N'update ' + @table_name + N'
			set tx_state = ''NA'' where
			tx_state = ''NC'''
		EXEC sp_executesql @query
		DROP TABLE #tmpcursor3
  end
  