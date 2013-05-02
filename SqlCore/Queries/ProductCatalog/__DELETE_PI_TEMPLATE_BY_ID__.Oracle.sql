
                declare
                    cursor c1 is 
                    select table_name from user_constraints where r_constraint_name in
                    (select constraint_name from user_constraints
                    where table_name ='T_RSCHED' and constraint_type in ('P','U'));
                    v_id_template int := %%ID_TEMPLATE%%;
                begin
                    for i in c1 loop
                        execute immediate 'delete '||i.table_name||' where id_sched in 
                        (select id_sched from t_rsched where id_pi_template = '|| CAST(v_id_template as varchar2) || ')';
                    end loop;
                    delete from t_pl_map where id_pi_template   = v_id_template;
                    delete from t_pi_template where id_template = v_id_template;
                end;
            