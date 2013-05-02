
/*
  Proc: DeployPartitionedTable

  Calls DeployPartitionedTable for all partitioned tables.
*/
CREATE OR REPLACE
procedure DeployPartitionedTable(
  p_tab varchar2
  )
authid current_user 
as

  cnt int;
  rowcnt int;
  
  defdb varchar2(30);  /* default part info */
  defstart int;
  defend int;
  isconv int;   /* is conversion? */
  
begin

  /* Nothing to do if system isn't enabled for partitioning */
  if dbo.isSystemPartitioned() = 0 then
    dbms_output.put_line('System not enabled for partitioning.');
    return;
  end if;

  /* Count active partitions. */
  
  /*
  insert into tmp_partns_deploy
    select p.id_partition, partition_name, b_default,
      dt_start, dt_end, id_interval_start, id_interval_end
    from t_partition p
    where b_active = 'Y'
    order by p.dt_end;
  */

  select count(1) into cnt 
  from t_partition 
  where b_active = 'Y';

  if (cnt < 2) then
    raise_application_error(-20000, 'Found '|| cnt ||' active partitions. Expected at least 2 (including default).');
  end if;
  
  /* Make sure there's only one default partition. */
  select count(1) into cnt 
  from t_partition
  where b_default = 'Y' and b_active = 'Y';

  if (cnt != 1) then
    raise_application_error(-20000, 'Found '|| cnt ||' default partitions. Expected one.');
  end if;

  /* If the table is not yet parititoned, then this a conversion */
  select count(1) into isconv from dual
  where not exists (select 1 from user_part_tables
    where upper(table_name) = upper(p_tab)
    );

  if isconv = 1 then
    /* Do the converstion.  Only once per table.
      When this call completes the table will be partitioned with
      a default paritions only.  The split op still has to be done. */
    DupPartitionedTable(p_tab);
  end if;
  
  /* Add as many partitions as needed. */
  ExtendPartitionedTable(p_tab);
  
  /* Rebuild UNUSABLE global indexes */
  RebuildGlobalIndexes(p_tab);
  
  /* Enable all unique constraints (that are DISABLED) */
  AlterTableUniqueConstraints(p_tab, 'enable');

  /* Rebuild UNUSABLE local index partitions. */
  RebuildLocalIndexParts(p_tab);

end DeployPartitionedTable;       
  