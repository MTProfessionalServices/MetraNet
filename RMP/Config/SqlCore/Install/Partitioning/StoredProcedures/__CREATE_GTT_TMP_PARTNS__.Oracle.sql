
create global temporary table tmp_partns (
  partition_name nvarchar2(30),
  dt_start date,
  dt_end date,
  interval_start int,
  interval_end int,
  result varchar2(2000) 
  ) on commit preserve rows
      