
create global temporary table tmp_tab_partns(
  table_name varchar2(30), 
  partition_name varchar2(30), 
  tablespace_name varchar2(30), 
  range_spec number(10),
  high_value clob,
  high_value_length number
  )
     