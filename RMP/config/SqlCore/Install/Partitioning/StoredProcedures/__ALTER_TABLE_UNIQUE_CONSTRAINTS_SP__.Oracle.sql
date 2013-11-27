
/* 
  Proc: AlterTableUniqueConstraints

  Enables or disables all unique/primary key constraints

*/
CREATE OR REPLACE
procedure AlterTableUniqueConstraints(
  p_tab varchar2,
  p_cmd varchar2  /* enable or disable */
  )
as

  ix int;
  cons_ddl str_tab;

begin

  dbms_output.put_line('AlterTableUniqueConstraints: '
    || p_cmd || ' all unique constraints on ' || p_tab);

  select 'alter table ' || table_name || ' '
    || p_cmd || ' constraint ' || constraint_name
  bulk collect into cons_ddl
  from (select 
          uc.table_name,
          uc.constraint_name,
          uc.constraint_type,
          column_name,
          position
        from user_cons_columns ucc
        join user_constraints uc
          on uc.constraint_name = ucc.constraint_name
        where constraint_type in ('P', 'U')
          and lower(uc.table_name) = lower(p_tab)
          and status != upper(p_cmd||'D')
          order by position)
  group by table_name, constraint_name;
  
  if cons_ddl.first is not null then
    for ix in cons_ddl.first .. cons_ddl.last loop
      dbms_output.put_line('  ' || cons_ddl(ix));
      execute immediate cons_ddl(ix);
    end loop;
  else
    dbms_output.put_line('AlterTableUniqueConstraints: Nothing to ' || p_cmd);
  end if;

end AlterTableUniqueConstraints;
   