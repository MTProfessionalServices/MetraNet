CREATE or replace PROCEDURE ANALYZE (p_table_name varchar2)
as
v_rows_changed number(10);
v_query varchar2(4000);
v_svctablename varchar2(255);
v_id_svc varchar2(10);
v_firstpass number(10);
l_cur       sys_refcursor;
ro rowid;
tx_uid1 t_acc_usage.tx_uid%TYPE;
begin
 /* mark the successful rows as analyzed.*/
 v_query := 'update ' || p_table_name ||         ' rr set tx_state = ''A''
        where exists (select 1 from t_acc_usage acc
                      where rr.id_sess = acc.id_sess and rr.id_interval = acc.id_usage_interval)
        and tx_state = ''I''';
  execute immediate v_query;
  /* set the id_parent_source_sess correctly for the children already */  /* identified by now (successful only)*/
  v_query := 'update ' || p_table_name || ' rr set id_parent_source_sess =
		  (select acc.tx_uid
		  from t_acc_usage acc
		  where rr.id_parent_sess = acc.id_sess
		  and acc.id_usage_interval = rr.id_interval
		  and acc.id_parent_sess is null)
		  where rr.id_parent_source_sess is null
		  and rr.tx_state = ''A''';
   execute immediate v_query;
   
   /* find parents for successful sessions*/
   v_query := 'insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
    select
            seq_' || p_table_name || '.NEXTVAL,
            tmp.tx_UID,    /* id_source_sess*/
            tmp.tx_batch,    /* tx_batch*/
            tmp.id_sess,    /* id_sess*/
            tmp.id_parent_sess,    /* id_parent*/
            null,                /* TODO: root*/
            tmp.id_usage_interval,    /* id_interval*/
            tmp.id_view,        /* id_view*/
            case aui.tx_status when ''H'' then ''C'' else ''A'' end, 
            tmp.id_svc,        /* id_svc*/
            NULL, /* id_parent_source_sess*/
            tmp.id_acc,
            tmp.amount,
            tmp.am_currency
        from  
            (select auparents.tx_uid, auparents.tx_batch, auparents.id_sess, auparents.id_parent_sess,
            auparents.id_usage_interval, auparents.id_view, auparents.id_svc, auparents.id_acc, auparents.amount,
            auparents.am_currency  from t_acc_usage auparents
            inner join ' || p_table_name || ' rr
            on rr.id_parent_sess = auparents.id_sess
            and auparents.id_usage_interval = rr.id_interval
            group by auparents.id_parent_sess, auparents.tx_uid, auparents.tx_batch, auparents.id_sess, auparents.id_parent_sess,
            auparents.id_usage_interval, auparents.id_view, auparents.id_svc, auparents.id_acc, auparents.amount,
            auparents.am_currency) tmp
            inner join t_acc_usage_interval aui on tmp.id_usage_interval = aui.id_usage_interval
            and tmp.id_acc = aui.id_acc
        where not exists (select 1 from '|| p_table_name || ' rr1 where rr1.id_sess = tmp.id_sess and tmp.id_usage_interval =rr1.id_interval)' ;
    execute immediate v_query;

    /* find children for successful sessions*/
    v_query := 'insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root,
						id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
            select
            seq_' || p_table_name || '.NEXTVAL,
            au.tx_UID,	/* id_source_sess*/
            au.tx_batch,	/* tx_batch*/
            au.id_sess,	/* id_sess*/
            au.id_parent_sess,	/* id_parent*/
            null,			/* TODO: root*/
            au.id_usage_interval,	/* id_interval*/
            au.id_view,		/* id_view*/
            case aui.tx_status when ''H'' then ''C'' else ''A'' end, /* tx_state*/
            au.id_svc,	/* id_svc*/
            rr.id_source_sess, /* id_parent_source_sess*/
						au.id_acc,
						au.amount,
			      au.am_currency
            from t_acc_usage au
            inner join ' || p_table_name || ' rr on au.id_parent_sess = rr.id_sess
            			and au.id_usage_interval = rr.id_interval
            inner join t_acc_usage_interval aui on au.id_usage_interval = aui.id_usage_interval
                  and aui.id_acc = au.id_acc
            where not exists (select 1 from ' || p_table_name || ' rr1 where rr1.id_sess = au.id_sess and rr1.id_interval = au.id_usage_interval)';

    execute immediate v_query;
    
    v_rows_changed := 1;
    v_firstpass := 1;
    /* complete the compound for failure cases.  In t_failed_transaction, you will have only the failed*/
    /* portion of the failed transaction. */
    while (v_rows_changed > 0)
    loop
        v_rows_changed := 0;
        If (v_firstpass = 1) then
            v_firstpass := 0;
        end if;
        /* find children for failed parent sessions*/
        /* this query gives us the tables where the children for the parents identified may live.*/
         v_query :=  'select distinct slog.nm_table_name, cast(ed.id_enum_data as nvarchar2(10))
				from ' || p_table_name || '  rr
				inner join t_failed_transaction ft
				on rr.id_source_sess = ft.tx_failureCompoundID
				inner join t_session_set ss
				on ss.id_ss = ft.id_sch_ss
                inner join t_session_set childss
				on ss.id_message = childss.id_message
				inner join t_enum_data ed
				on ed.id_enum_data = childss.id_svc
				inner join t_service_def_log slog
				on upper(ed.nm_enum_data) = upper(slog.nm_service_def)
				where id_parent_source_sess is null and tx_state = ''E''
				and childss.b_root = ''0''';
         OPEN l_cur for v_query;
         loop
            FETCH l_cur into v_svctablename, v_id_svc;
            exit when l_cur%NOTFOUND;
            dbms_output.put_line( v_svctablename);
            v_query := 'insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			select 
			seq_' || p_table_name || '.NEXTVAL,
			conn.id_source_sess,	/* id_source_sess*/
			conn.c__CollectionID,	/* tx_batch*/
			NULL,	/* id_sess*/
			NULL,	/* id_parent_sess*/
			NULL,			/* TODO: root*/
			NULL,	/* id_interval*/
			NULL,		/* id_view*/
			''E'',			/* tx_state*/
			'|| v_id_svc || ' , 	/* id_svc*/
			conn.id_parent_source_sess,
			NULL,			 /* payer */	
			NULL,
			NULL
			from ' || p_table_name || ' rr
			inner join ' || v_svctablename || ' conn
			on rr.id_source_sess = conn.id_parent_source_sess
			where rr.id_parent_source_sess is null and tx_state = ''E''
			and not exists (select * from ' || p_table_name || ' where ' ||  p_table_name || '.id_source_sess = conn.id_source_sess)';
            execute immediate v_query;
            v_rows_changed := v_rows_changed + SQL%ROWCOUNT;
         END loop;
         CLOSE l_cur;
         /* find parents for failed children sessions*/
         /* this query gives us all the svc tables in which the parents may live*/
          v_query :=  'select distinct slog.nm_table_name, cast(ed.id_enum_data as nvarchar2(10))
				from ' || p_table_name || ' rr
				inner join t_failed_transaction ft
				on rr.id_source_sess = ft.tx_failureID
				inner join t_session_set ss
				on ss.id_ss = ft.id_sch_ss
				inner join t_session_set parentss
				on ss.id_message = parentss.id_message
				inner join t_enum_data ed
				on ed.id_enum_data = parentss.id_svc
				inner join t_service_def_log slog
				on upper(ed.nm_enum_data) = upper(slog.nm_service_def)
				where id_parent_source_sess is not null
				and tx_state = ''E''
				and ss.id_svc <> parentss.id_svc
				and parentss.b_root = ''1''';
          OPEN l_cur for v_query;
          loop
            FETCH l_cur into v_svctablename, v_id_svc;
            exit when l_cur%NOTFOUND;
            dbms_output.put_line( v_svctablename);
            v_query := 'insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
			 select
			 seq_' || p_table_name || '.NEXTVAL,
			 call.id_source_sess,	/* id_source_sess*/
			 call.c__CollectionID,	/* tx_batch*/
			 NULL,	/* id_sess*/
			 NULL,	/* id_parent_sess*/
			 NULL,			/* TODO: root*/
			 NULL,	/* id_interval*/
			 NULL,		/* id_view*/
			 ''E'',			/* tx_state */
			 '|| v_id_svc || ' , 	/* id_svc*/
			 call.id_parent_source_sess,
			 null, /* id_payer */	
			 null,
			 null
			 from ' || p_table_name || ' rr
			 inner join ' || v_svctablename || ' call
			 on rr.id_parent_source_sess = call.id_source_sess
			 where rr.id_parent_source_sess is not null and tx_state = ''E''
			 and not exists (select * from ' || p_table_name || ' where ' ||  p_table_name || '.id_source_sess = call.id_source_sess)';
            execute immediate v_query;
            v_rows_changed := v_rows_changed + SQL%ROWCOUNT;
          END loop;
          CLOSE l_cur;
    end loop;
    
    /* handle suspended and pending transactions.  We know we will have identified   all suspended and pending parents.  Only children need to be looked at.   following query tells us which tables to look for the children   changing the cursor query.. for whatever reason,it takes too long, even when there are    no suspended transactions (CR: 13059) */
    v_query :=  ' select distinct slog.nm_table_name , cast(ss2.id_svc as nvarchar2(10))
			 from t_session_set ss2
			 inner join t_enum_data ed
			 on ss2.id_svc = ed.id_enum_data
			 inner join t_service_def_log slog
			 on upper(ed.nm_enum_data) = upper(slog.nm_service_def)
			 where id_message in (
			 select ss.id_message from ' || p_table_name || ' rr
			 inner join t_session sess
			 on sess.id_source_sess = rr.id_source_sess
			 inner join t_session_set ss
			 on sess.id_ss = ss.id_ss
			 inner join t_message msg
			 on msg.id_message = ss.id_message
			 where rr.tx_state = ''NC'')
			 and ss2.b_root = ''0''';
    OPEN l_cur for v_query;
    loop
        FETCH l_cur into v_svctablename, v_id_svc;
        exit when l_cur%NOTFOUND;
                dbms_output.put_line( v_svctablename);
                v_query := ' insert into ' || p_table_name || ' (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
				    select seq_' || p_table_name || '.NEXTVAL, svc.id_source_sess, null,
				    null, null, null, null, null, ''NA'', ' || v_id_svc || ' , rr.id_source_sess, null, null, null
			        from ' || p_table_name || ' rr
			        inner join ' || v_svctablename || ' svc
				    on rr.id_source_sess = svc.id_parent_source_sess
				    where rr.tx_state = ''NC''
				    and svc.id_source_sess not in (select id_source_sess from ' || p_table_name || ')';
                execute immediate v_query;
    END loop;
    CLOSE l_cur;
            
    v_query :=  'update ' || p_table_name || '
	             set tx_state = ''NA'' where
	             tx_state = ''NC''';
    execute immediate v_query;
end;