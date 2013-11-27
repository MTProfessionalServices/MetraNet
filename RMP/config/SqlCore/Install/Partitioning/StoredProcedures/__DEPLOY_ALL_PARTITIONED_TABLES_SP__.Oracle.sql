
/*
  Proc: DeployAllPartitionedTables

  Calls DeployPartitionedTable for all partitioned tables.

*/
CREATE OR REPLACE
procedure DeployAllPartitionedTables authid current_user  as begin    
/* Abort if system isn't enabled for partitioning */

  if dbo.IsSystemPartitioned() = 0 then
    raise_application_error(-20000, 'System not enabled for partitioning.');
  end if;

  for x in (select nm_table_name 
        from t_prod_view 
        order by nm_table_name)
  loop

    dbms_output.put_line('DeployAllPartitionedTables: Depolying '|| x.nm_table_name);
    DeployPartitionedTable(x.nm_table_name);

  end loop;

end DeployAllPartitionedTables;
       