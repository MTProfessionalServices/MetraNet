
CREATE OR REPLACE
procedure AddUniqueKeyMetadata(
  tabname varchar2,
  consname varchar2,
  cols varchar2
  )
as
  pvid int := null;
  ukid int := null;
  propid int := null;
  posn int := 0;
  colname varchar2(300);
begin

  /*  Get product view id */
  for x in (select id_prod_view
        from t_prod_view
        where lower(nm_table_name) = lower(tabname))
  loop
    pvid := x.id_prod_view;
    exit;
  end loop;

  if (pvid is null) then
    raise_application_error(-20000,
      'Product view ['|| tabname ||'] does not exist.');
    return;
  end if;

  /* Insert the unique key name */
  select seq_t_unique_cons.nextval into ukid from dual;

  insert into t_unique_cons (
      id_unique_cons, id_prod_view, constraint_name, nm_table_name)
    values (
      ukid, pvid, consname, 'not used');

  dbms_output.put_line('uk: ' || ukid);

  for col in (select column_value as name
        from table(dbo.csvtostrtab(cols)))
  loop
    colname := col.name;
    posn := posn + 1;

    /* Remove whitespace(spaces, tabs, newlines) */
    colname := replace(colname, ' ');
    colname := replace(colname, chr(9));
    colname := replace(colname, chr(10));

    /* Get property id of column */
    select id_prod_view_prop into propid
    from t_prod_view_prop
    where id_prod_view = pvid
      and lower(nm_column_name) = lower(colname);

    /* Insert new column */
    insert into t_unique_cons_columns
      values (ukid, propid, posn);

  end loop;

end AddUniqueKeyMetadata;
 	