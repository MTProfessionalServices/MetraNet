
create global temporary table tmp_partns_deploy (
  id_partition int,
  partition_name varchar2(30),
  b_default char(1),
  dt_start date,
  dt_end date,
  interval_start int,
  interval_end int
  )
      