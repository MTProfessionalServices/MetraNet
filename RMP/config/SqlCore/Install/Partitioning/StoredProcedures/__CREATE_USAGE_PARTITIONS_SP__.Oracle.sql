
/*
  Proc: CreateUsagePartitions

  Creates usage partitions for active and unassigned intervals.  Updates
  the t_partition to match.

*/
CREATE OR REPLACE
procedure CreateUsagePartitions(
  p_cur out sys_refcursor
  )
authid current_user
as
  /* Specs for creating partitions */
  enabled char(1);
  cycleid int;
  datasize int;
  logsize int;
  path varchar2(2000);
  intervalstatus varchar2(10);
  
  /* Vars for iterating through the new partition list */
  partns sys_refcursor;
  partitionname varchar2(30);
  dtstart date;
  dtend date;
  intervalstart int;
  intervalend int;
  result varchar2(2000);

  cnt int;
begin
  
  /* Abort if system isn't enabled for partitioning */
  if dbo.IsSystemPartitioned() = 0 then
    dbms_output.put_line('System not enabled for partitioning.');
    open p_cur for select * from tmp_partns where 1=0;
    return;
  end if;
  
  /* Get database size params */
  select partition_data_size, partition_log_size
  into datasize, logsize
  from t_usage_server;
  
  /* Determine if this is a conversion and include 
    hard-closed intervals if so. */

  /* Is t_acc_usage partitioned? */
  select count(1) into cnt from dual
    where exists (select 1 
      from user_part_tables
      where table_name like upper('t_acc_usage'));

  intervalstatus := case cnt
    when 0 then '[BO]' else '[HBO]' end;

  /* Get list of new partition names*/
  /* Returns a cursor containing:
      dt_start,
      dt_end,
      interval_start,
      interval_end
  */
  GeneratePartitionSequence(partns);

  /* Iterate through partition sequence */
  loop 
    fetch partns into dtstart, dtend, intervalstart, intervalend;
    exit when partns%notfound;

    dbms_output.put_line('dtstart=' || to_char(dtstart));
    dbms_output.put_line('dtend=' || to_char(dtend));
    dbms_output.put_line('intervalstart=' || to_char(intervalstart));
    dbms_output.put_line('intervalend=' || to_char(intervalend));

    /* Construct database name */
    select user || '_' || to_char(dtend, 'yyyymmdd')
    into partitionname from dual;
    dbms_output.put_line('partitionname=' || partitionname);

    /* Create the partition database and check exception */
    CreatePartitionDatabase(partitionname, datasize, logsize);
  
    /* Insert partition metadata */
    insert into t_partition (id_partition,
        partition_name, b_default, 
        dt_start, dt_end, id_interval_start, id_interval_end, b_active)
      values (seq_t_partition.nextval,
        trim(partitionname), 'N', 
        dtstart, dtend, intervalstart, intervalend, 'Y');
      
    if not sql%found then
      raise_application_error(-20000, 'Cannot insert partition metadata into t_partition.');
    end if;
    
    commit;

    /* Save partition info for reporting */
    insert into tmp_partns values (partitionname, dtstart, dtend, 
      intervalstart, intervalend, result);
  
  end loop;
  
  close partns;
  
  /* Create or fixup the default partition  */
  CreateDefaultPartition;
  
  /* Finished creating databases. 
  
    Include default partition info with new partition list 
    if new partitions were created. Return the list as result 
    set for reporting.
  */

  insert into tmp_partns
    select partition_name, dt_start, dt_end,
           id_interval_start, id_interval_end, ''
    from t_partition
    where b_default  = 'Y'
      and exists (select 1 from tmp_partns);
  
  open p_cur for 
    select * from tmp_partns order by dt_start;

end CreateUsagePartitions;
       