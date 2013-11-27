
create or replace
procedure GetNextStoragePath(
  p_path out varchar2 /* fully qualified filesystem pathname */
  )
AS
  pathcnt int := null;
  next_id int := null;
  curr_id int := null;
begin

  /* get count of paths */
  select count(*) into pathcnt from t_partition_storage;

  if (pathcnt < 1) then
    raise_application_error(-20000, 'There are no storage paths defined.');
  end if;
  
  /* get next path */
  for x in (
        select path, id_path
        from t_partition_storage
        where lower(b_next) = 'y'
        ) loop
    p_path := x.path;
    curr_id := x.id_path;
  end loop;

  /* if next flag isn't found or too many found, use first */
  if (curr_id is null) then
    select path, id_path into p_path, curr_id
    from t_partition_storage
    where id_path = (select min(id_path) 
                     from t_partition_storage);
  end if;
  
  /* calculate the new next-path */
  next_id := mod(curr_id, pathcnt)+1;

  /* advance the b_next flag */
  update t_partition_storage set b_next = 'N';
  update t_partition_storage set b_next = 'Y' where id_path = next_id;

  commit;

end GetNextStoragePath;
   