
/*
  Proc: GeneratePartitionSequence

  Returns a list partitions based on current partition type
  and active intervals.

*/
create or replace
procedure GeneratePartitionSequence(
  partns out sys_refcursor
  )
AS
  cnt int;  
  cycleid int;
  intervalstatus varchar2(10);

  dtmin date;
  dtmax date;
  dtend date;

  dtstart date;
begin
  dbms_output.put_line('Invoked GeneratePartitionSequence().');

  /* Get the partition cycle from config table
  */
  select partition_cycle into cycleid from t_usage_server;
  dbms_output.put_line('cycleid=' || to_char(cycleid));

  /*  Only 4 cycles supported 33, 34, 383, 520 (see check for supported cycle ids in __SET_PARTITION_OPTIONS_SP__ under comment -- find cycle id for a supported partition cycle*/  
  if (cycleid not in (33, 34, 383, 520)) then
    raise_application_error(-20000, 'Cycle '|| cycleid ||' not supported.');
  end if;

  /* Determine if this is a conversion and include 
    hard-closed intervals if so.
    */
  intervalstatus := '[BO]';

  /* Is t_acc_usage partitioned? */
  select count(1) into cnt from dual
    where exists (select 1 
      from user_part_tables
      where table_name like upper('t_acc_usage'));

  if cnt > 0 then
    intervalstatus := '[HBO]';
  end if;

  /* Get high and low end-dates for all active intervals.
  */
  select min(dt_end), max(dt_end) into dtmin, dtmax
  from t_usage_interval ui
  where regexp_like(ui.tx_interval_status, intervalstatus, 'i');
  dbms_output.put_line('dtmin=' || to_char(dtmin));
  dbms_output.put_line('dtmax=' || to_char(dtmax));

  /* Get end-date of eldest active partition.  If there aren't
    any partitions yet then use lowest of active interval end-dates.
  */
  for x in (
      select max(dt_end) as maxend
      from t_partition
      where upper(b_active) = 'Y')
  loop
    dtend := x.maxend;
  end loop;
  dbms_output.put_line('dtend=' || to_char(dtend));

  /* The start of the new partition range is always the day
    after the last partition ends.  If there is no prior
    partition, then use the youngest of the interval end-dates.
  */
  dtstart := nvl(dtend + 1, dtmin);
  dbms_output.put_line('dtstart=' || to_char(dtstart));

  /*-- debugging...
  cycle := 30;
  dtend := null;
  dtend := '2005-01-15 23:59:59';
  dtmin := '2005-05-31 23:59:59'; 
  dtmax := '2005-09-05 23:59:59';
  */

  /* Round start dates down to whole day
  */
  dtmin := trunc(dtmin);
  dtstart := trunc(dtstart);

  /* debugging
  select cycleid as cyc, dtend as dtend, dtstart as start, 
    dtmin as dtmin, dtmax as dtmax
  */

  /* Get the partition sequence
  */
  open partns for 
  select 
  /* The real start of the cycle; untruncated */
  /* dt_start as interval_start, */
  
  /* dt_start might be the truncated start of the an interval. 
     if the start of the new partition doesn't cleanly
     adjoin and exiting partition then it starts the day after. */
  case when dtend is not null and dtstart > dt_start 
       then dtstart else dt_start end 
    as dt_start,
  
  /* dt_end is the end of the interval */
  dt_end,
  
  /* interval_start is a usage-interval key equivalent
     used to constrain the partition's lower bound. */
  extract(day from case when dtend is not null and dtstart > dt_start 
        then dtstart else dt_start end
        - to_timestamp('1970-01-01', 'yyyy-mm-dd'))
      * power(2,16)
    as interval_start,
  
  /* interval_end is a usage-interval key equivalent
     used to constrain the partition's upper bound */
  extract(day from dt_end 
          - to_timestamp('1970-01-01', 'yyyy-mm-dd'))
      * power(2,16)
      + (power(2,16) - 1) 
    as interval_end
    
  from t_pc_interval 
  where id_cycle = cycleid
  and dt_end > dtstart    
  and dt_start <= dtmax
  order by dt_end;

end GeneratePartitionSequence;
   