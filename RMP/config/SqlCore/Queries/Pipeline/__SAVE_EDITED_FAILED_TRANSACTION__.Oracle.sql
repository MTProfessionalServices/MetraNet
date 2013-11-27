
declare
    deleteCursor sys_refcursor;
    v_sql        varchar2(4000);
    c varchar2(4096);
begin

    /* updates t_svc tables with any edits (also updates non-edited values) */
    %%SVC_UPDATE_STATEMENTS%%

    /*
    deletes the requested children (if any) from t_svc tables
    */

    %%INSERT_CHILDREN_TO_DELETE%%

  v_sql := '
    select svclog.nm_table_name  
    FROM tmp_children children
    INNER JOIN t_session s ON s.id_source_sess = children.id_source_sess
    INNER JOIN t_session_set ss ON ss.id_ss = s.id_ss
    INNER JOIN t_enum_data enum ON enum.id_enum_data = ss.id_svc
    INNER JOIN t_service_def_log svclog ON upper(svclog.nm_service_def) = upper(enum.nm_enum_data)';
 
    /* executes the delete statements*/
    open deletecursor for v_sql;


    loop
        fetch deletecursor into c;
        if deletecursor%notfound then 
					exit;
        end if;
        
        execute immediate 'delete from ' || c	|| ' where id_source_sess in (select id_source_sess from tmp_children)';

    end loop;
 
    close deletecursor;
    commit;
end;

			