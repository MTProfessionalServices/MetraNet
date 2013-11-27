
/* 
  Proc: ExtendPartitionedTable

  Extends a partitioned table onto new partitions.

*/
CREATE OR REPLACE
procedure ExtendPartitionedTable(
  p_tab varchar2 /* table to convert */ 
 ) 
authid current_user as 
 
  cnt int;
  partn_tab varchar2(30);  /* temp name for new partitioned table */
  highend_partn varchar2(30);  /* highend default partition name */

  ix int;
  one_split varchar2(2000);
  split_ddl str_tab := str_tab();
  
  nl char(1) := chr(10);
  tab char(2) := '  ';
  tab2 char(4) := tab || tab;

begin

  dbms_output.put_line('ExtendPartitionedTable: ' || p_tab);

  /* Abort if system isn't enabled for partitioning */
  if dbo.isSystemPartitioned() = 0 then
    raise_application_error(-20000, 'System not enabled for partitioning.');
  end if;

  /* This table should already be partitioned. */
  select count(1) into cnt from dual
  where not exists (select 1 from user_part_tables
    where upper(table_name) = upper(p_tab)
    );
    
  if cnt > 0 then
     dbms_output.put_line('ExtendPartitionedTable: '|| p_tab 
      ||' is not partitioned.');
      return;
  end if;
  
  /* Is this table missing any partitions? 
  
    We need to join MetraNet's t_partition (p) table with Oracle's 
    user_tab_partitions (utp) table on utp.high_value.  
    
    But, high_value has deprecated type LONG.  LONG's can't be used in a join
    nor converted to another usable type. Only one operation is allowed on
    LONG's and in only one context.  We use this operation/context below
    to get a usable query.  
  */
  
  /* Get the values we need from user_tab_partitions. Converting high_value
    to a CLOB in the process. */
  delete from tmp_tab_partns;
  insert into tmp_tab_partns
    select table_name,
      partition_name,
      tablespace_name,
      0,  /* range_spec */
      to_lob(high_value),
      high_value_length
    from user_tab_partitions
    where table_name = upper(p_tab);

  /* Convert high_value to a NUMBER suitable for joining with a 
    partition range interval id */
  update tmp_tab_partns 
    set range_spec = case to_char(high_value)
        when 'MAXVALUE' then dbo.maxpartitionbound
        else to_number(high_value) end;

  /* Get name of the high end default partition
  */
  select partition_name into highend_partn
  from tmp_tab_partns
  where range_spec = dbo.maxpartitionbound;
  
  /* Now, find missing partitions in chronological order and
    build a list of split partition statements.
  */
  for x in (    
      select /*
        p.id_interval_start,
        p.id_interval_end,
        --dt_start, dt_end, 
        p.b_default,
        p.b_active,
        ttp.table_name,
        ttp.partition_name,
        ttp.tablespace_name,
        ttp.range_spec as ttp_range_spec,  */
        p.partition_name as tblspc_name,
        p.id_interval_end + 1 as range_spec
      from t_partition p
      full outer join tmp_tab_partns ttp
        on ttp.range_spec = p.id_interval_end + 1
      where nvl(p.b_active, 'Y') = 'Y'
        and ttp.range_spec is null
      order by id_interval_end)
  loop

    one_split := 'alter table ' || p_tab 
      || ' split partition ' || highend_partn || ' at (' || x.range_spec || ')'
      || ' into (partition tablespace ' || x.tblspc_name || ', '
      || 'partition ' || highend_partn || ')';
      
    split_ddl.extend;
    split_ddl(split_ddl.last) := one_split;
  
  end loop;
  
  /* Exec the split ddl list */
  if split_ddl.first is not null then
    for ix in split_ddl.first .. split_ddl.last loop

      dbms_output.put_line('ExtendPartitionedTable: '|| split_ddl(ix));
      execute immediate split_ddl(ix);

    end loop;
  else
    dbms_output.put_line('ExtendPartitionedTable: '|| p_tab 
      ||' is already fully partitioned.');
  end if;

end ExtendPartitionedTable;
   