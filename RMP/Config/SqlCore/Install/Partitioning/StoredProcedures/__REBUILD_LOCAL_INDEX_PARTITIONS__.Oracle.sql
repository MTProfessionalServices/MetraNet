
/* 
  Proc: RebuildLocalIndexParts

  Rebuilds all unsable index partitons for a single table.

*/
create or replace
procedure RebuildLocalIndexParts(
  p_tab varchar2  /* table to convert */
  )
authid current_user
as
  cnt int;

  ix int;
  idx_ddl str_tab;

  nl char(1) := chr(10);
  tab char(2) := '  ';
  nlt char(3) := nl || tab;
  
begin

  dbms_output.put_line('RebuildLocalIndexParts: ' || p_tab);

  /* Abort if system isn't enabled for partitioning */
  if dbo.isSystemPartitioned() = 0 then
    raise_application_error(-20000,   'System not enabled for partitioning.');
  end if;

  /* Make sure this table is partitioned */
  select count(1) into cnt from dual
  where not exists (select 1 from user_part_tables
    where upper(table_name) = upper(p_tab)
    );
    
  if cnt > 0 then
     dbms_output.put_line('RebuildLocalIndexParts: '|| p_tab 
      ||' is not a partitioned table.');
     return;
  end if;

  /* Generate the rebuild index ddl for unsable partitions */
  select 'alter index ' || uip.index_name 
    || ' rebuild partition ' || uip.partition_name || ' logging'
  bulk collect into idx_ddl
  from user_part_indexes upi
  join user_ind_partitions uip
    on uip.index_name = upi.index_name
  where table_name = upper(p_tab)
    and locality = 'LOCAL'
    and status = 'UNUSABLE'
  order by upi.index_name, partition_name;

  /* Rebuld unusable index partitions  */
  if idx_ddl.first is not null then
    for ix in idx_ddl.first..idx_ddl.last loop
      dbms_output.put_line('  ' || idx_ddl(ix));
      execute immediate idx_ddl(ix);
    end loop;
  else
    dbms_output.put_line('RebuildLocalIndexParts: All index partitions already USABLE.');
  end if;

  
end RebuildLocalIndexParts;
   