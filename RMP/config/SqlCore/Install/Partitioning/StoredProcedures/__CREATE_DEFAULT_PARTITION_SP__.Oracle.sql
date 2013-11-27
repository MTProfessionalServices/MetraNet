
/*
Proc: CreateDefaultPartition
  Creates the default parition tablespace (if needed) 
  and realigns the t_partition table to match.

*/
create or replace 
procedure CreateDefaultPartition 
authid current_user 
as

  partitionid int;
  partitionname varchar2(30);
  dtstart date;
  dtend date;
  intervalstart int;
  intervalend int;
  
  datasize int;
  logsize int;

begin
      
  /* Create or update the default partition
  
    Get properties of new default partition based on existing active 
    partitions.  The default covers the unbounded date ranges above 
    and below the set of active continuous partitions.
    
    Here, in Oracle, it`s really only the upper range, but we calc
    the metadata for consistency with SqlServer.
  */

  for x in (
        select 
          /* end + 1 sec is start of default */
          dbo.addsecond(max(dt_end)) as dtstart,
      
          /* start - 1 sec is end of default */
          dbo.subtractsecond(min(dt_start)) as dtend,
      
          /* interval start is end + 1 sec */
          dbo.daysFromPartitionEpoch(dbo.addsecond(max(dt_end)))
            * power(2,16) as intervalstart,
        
          /* interval end is start - 1 sec */
          dbo.daysFromPartitionEpoch(dbo.subtractsecond(min(dt_start)))
            * power(2,16) + (power(2,16) - 1) as intervalend

        from t_partition  
        where upper(b_active) = 'Y')
  loop
    dtstart := x.dtstart;
    dtend := x.dtend;
    intervalstart := x.intervalstart;
    intervalend := x.intervalend;
  end loop;
  
  /* If there are no active partitions, then the default 
    covers all intervals.
  */
  if (dtstart is null) then
    dtstart := trunc(sysdate);
    dtend := dbo.subtractsecond(dtstart);

    intervalstart := dbo.daysFromPartitionEpoch(dtstart)
      * power(2,16);

    intervalend := dbo.daysFromPartitionEpoch(dtend)
      * power(2,16) + (power(2,16) - 1);
  end if;
      
  /* Get partition database params */
  select partition_data_size, partition_log_size
    into datasize, logsize
  from t_usage_server;
      
  /* Create the default partition tablespace */
  select user || '_default' into partitionname from dual;
  CreatePartitionDatabase(partitionname, datasize, logsize);

  /* Get id of default partition if it exists */
  for x in (
      select id_partition, rownum as rnum
      from t_partition where upper(b_default) = 'Y')
  loop
    partitionid := x.id_partition;
    if x.rnum > 1 then
      raise_application_error(-20000, 'Consistency failure: Found more than 1 default partition.');
    end if;
  end loop;
      
  /* Insert partition metadata if new, else update
  */
  if (partitionid is null) then
    insert into t_partition (id_partition,
        partition_name, b_default, 
        dt_start, dt_end, id_interval_start, id_interval_end, b_active)
      values (seq_t_partition.nextval,
        trim(partitionname), 'Y', 
        dtstart, dtend, intervalstart, intervalend, 'Y');
      
    if not sql%found then
      raise_application_error(-20000, 'Cannot insert into default database into t_partition.');
    end if;
  else
    update t_partition set
      dt_start = dtstart,
      dt_end = dtend,
      id_interval_start = intervalstart,
      id_interval_end = intervalend
    where id_partition = partitionid;

    if not sql%found then
      raise_application_error(-20000, 'Cannot update t_partition for default database'); 
    end if;
  end if;
  
  commit;

end CreateDefaultPartition;
    