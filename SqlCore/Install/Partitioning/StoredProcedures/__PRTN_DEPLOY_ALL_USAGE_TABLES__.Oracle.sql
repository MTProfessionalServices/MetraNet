
/*
  Proc: prtn_deploy_all_usage_tables

  Calls prtn_deploy_usage_table for Usage partitioned tables.

*/
CREATE OR REPLACE
procedure prtn_deploy_all_usage_tables authid current_user  as begin    
/* Abort if system isn't enabled for partitioning */

  if dbo.IsSystemPartitioned() = 0 then
    raise_application_error(-20000, 'System not enabled for partitioning.');
  end if;

  for x in (select nm_table_name 
        from t_prod_view 
        order by nm_table_name)
  loop

    dbms_output.put_line('prtn_deploy_all_usage_tables: Depolying '|| x.nm_table_name);
    prtn_deploy_usage_table(x.nm_table_name);

  end loop;

end prtn_deploy_all_usage_tables;
       