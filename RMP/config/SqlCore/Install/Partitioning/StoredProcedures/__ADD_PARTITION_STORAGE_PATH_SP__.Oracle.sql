
create or replace
procedure AddPartitionStoragePath(
  p_path varchar2  /* fully qualified filesystem pathname */
  )
AS
  nextid int;
begin

  /* get next path id */

  select coalesce(max(id_path), 0) + 1 into nextid
  from t_partition_storage;

  insert into t_partition_storage (id_path, b_next, path)
  values (nextid, 'N', p_path);

end AddPartitionStoragePath;
   