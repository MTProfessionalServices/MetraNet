/*
  Proc: CreatePartitionDatabase
    Creates a new tablespace for usage table partitions.
*/
CREATE OR REPLACE
procedure prtn_create_meter_partitions
authid current_user
AS

  meter_tablespace_name varchar2(50);  /* name of tablespace to create */

--OPT
  data_size int := 50;   /* size of each data file */
  log_size int := 12;   /* size of each log file */

-- DEL?
  cnt int;
  ts_ddl varchar2(4000);
  ts_name varchar2(2000);
  ts_opts varchar2(200);

  df_name varchar2(2000);
  df_size varchar2(200);
  df_opts varchar2(200);
  
  ix int;
  path varchar2(2000);
  paths str_tab;
  distrib_method varchar2(20);

begin

    select prtn_GetMeterPartFileGroupName() into meter_tablespace_name from dual;

  select partition_data_size, partition_log_size
    into data_size, log_size
  from t_usage_server;
  
  /* Abort if tablespace already exists */
  select count(1) into cnt from dual
  where exists (
    select 1 from user_tablespaces
    where tablespace_name = upper(meter_tablespace_name));
    
  if (cnt > 0) then  
    dbms_output.put_line('Tablespace '|| meter_tablespace_name ||' already exists.');
    return;
  end if;

  /* Create tablespace statement should look like this:
  
    create tablespace n_abcd
      datafile 
          'c:\oradata\01\n_abcd.dbf' size 5m reuse autoextend on next 100m maxsize unlimited,
          'c:\oradata\02\n_abcd.dbf' size 5m reuse autoextend on next 100m maxsize unlimited,
          'c:\oradata\03\n_abcd.dbf' size 5m reuse autoextend on next 100m maxsize unlimited,
          'c:\oradata\04\n_abcd.dbf' size 5m reuse  autoextend on next 100m maxsize unlimited
      logging extent management local segment space management auto 
  */

  ts_ddl := 'create tablespace ' || meter_tablespace_name || ' datafile ';
  df_size := ' size '|| data_size ||'m';
  df_opts := ' reuse autoextend on next 100m maxsize unlimited,';
  ts_opts:= ' logging extent management local segment space management auto';

  
  /* eventually distrib_method will come from t_usage_server table */
  distrib_method := 'roundrobin';

  if lower(distrib_method) = 'roundrobin' then
    GetNextStoragePath(path);
    paths := str_tab(path);
  elsif lower(distrib_method) = 'parallel' then
    select path 
    bulk collect into paths
    from t_partition_storage;
  else
    raise_application_error(-20000, 'Invalid distribution method: ' || distrib_method );
  end if;

  /* At least one data storage path must be defined */
  if paths.first is null then
    raise_application_error(-20000, 'There are no storage paths defined.');
  end if;

    dbms_output.put_line(paths(1));

    /* build datafile full path name; check and fix trailing path sep */
    df_name := '''' || rtrim(paths(1), '/\') || '/' 
      || meter_tablespace_name || '.dbf''';
    
    /* append filename, size and options */
    ts_ddl := ts_ddl || chr(10) || chr(9) 
      || df_name || df_size || df_opts;
    
  /* remove trailing comma, append tablespace opts */
  ts_ddl := rtrim(ts_ddl, ',') || chr(10) || chr(9) || ts_opts; 

  dbms_output.put_line('CreatePartitionDatabase: ts_ddl=' || ts_ddl);

  exec_ddl(ts_ddl);

end prtn_create_meter_partitions;
