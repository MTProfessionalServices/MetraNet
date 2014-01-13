
Create or replace Procedure BACKOUT(p_rerun_table_name varchar2, p_delete_failed_records VARCHAR2)
as
v_sql varchar2(4000);  /* values we get from the cursor*/
v_tablename varchar2(255);
v_id_view number(10);
tablename_cursor sys_refcursor;
begin
    /* update the state in t_session_state*/
    /* delete from the productviews.*/
    v_sql := 'select rr.id_view, pv.nm_table_name from
		  t_prod_view pv
		  inner join ' || p_rerun_table_name || N' rr on rr.id_view = pv.id_view
	   	  where rr.tx_state = ''A''
		  group by rr.id_view, pv.nm_table_name';

    OPEN tablename_cursor for v_sql;
    loop
        FETCH tablename_cursor into v_id_view, v_tablename;
        exit when tablename_cursor%NOTFOUND;

        v_sql := 'DELETE from ' || v_tablename || ' pv where exists
                    (select 1 from ' || p_rerun_table_name ||
                    ' rerun where rerun.id_sess = pv.id_sess
                    and pv.id_usage_interval = rerun.id_interval
                    and tx_state = ''A'')';

        execute immediate v_sql;

        /* delete from the prod view unique key tables, needs to happen if partioning is turned on.
        BackoutUniqueKeys (p_rerun_table_name, v_tablename); */
    END LOOP;
    CLOSE tablename_cursor;
    /* delete from t_acc_usage*/

    v_sql := 'delete from t_acc_usage acc where exists
	           (select 1 from ' || p_rerun_table_name ||
               ' rerun where acc.id_sess = rerun.id_sess
               and acc.id_usage_interval = rerun.id_interval
               and tx_state = ''A'')';
               
    EXEcute immediate v_sql;

    /* delete from t_acc_usage unique key tables
    BackoutUniqueKeys (p_rerun_table_name, 't_acc_usage'); */

    if (p_delete_failed_records = 'Y')   then
        /* delete errors from t_failed_transaction and t_failed_transaction_msix*/
        v_sql := 'delete from t_failed_transaction_msix msix
                where exists(
	   		    select 1 from t_failed_transaction ft,' || p_rerun_table_name || ' rr where 
          		    ft.id_failed_transaction = msix.id_failed_transaction
     			    and rr.id_source_sess = ft.tx_failurecompoundid
     			    and rr.tx_state = ''E'')';

        execute immediate v_sql;

        v_sql := 'delete from t_failed_transaction ft where exists
     		        (select 1 from  ' || p_rerun_table_name || ' rr
		        where ft.tx_failurecompoundid = rr.id_source_sess
     		        and rr.tx_state = ''E'')';

        EXECUTE immediate v_sql;
    END if;

    /* update the rerun table so we know these have been backed out*/
    v_sql := 'update ' || p_rerun_table_name ||
                ' set tx_state = ''B'' where (tx_state = ''A'' or tx_state = ''E'')';

    EXECUTE immediate v_sql;

end;
	
 