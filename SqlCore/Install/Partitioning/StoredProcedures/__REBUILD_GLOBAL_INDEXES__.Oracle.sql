
/* 
  Proc: RebuildGlobalIndexes

  Rebuilds all unsable global indexes for a single table.

*/
CREATE OR REPLACE
procedure RebuildGlobalIndexes(
  p_tab varchar2  /* table to convert */
  )
authid current_user
as
  cnt int;

  ix int;
  idx_ddl str_tab;

  nl char(1) := chr(10);
  tab char(2) := '  ';
  nlt char(3) := nl || tab;
  
begin

  dbms_output.put_line('RebuildGlobalIndexes: ' || p_tab);

  /* Generate the rebuild index ddl for unsable partitions */
  select 'alter index ' || ui.index_name || ' rebuild logging'
  bulk collect into idx_ddl
  from user_indexes ui
  where uniqueness = 'UNIQUE'
    and status = 'UNUSABLE'
    and table_name = upper(p_tab)
  order by ui.index_name;

  /* Rebuld unusable index partitions  */
  if idx_ddl.first is not null then
    for ix in idx_ddl.first..idx_ddl.last loop
      dbms_output.put_line('  ' || idx_ddl(ix));
      execute immediate idx_ddl(ix);
    end loop;
  else
    dbms_output.put_line('RebuildGlobalIndexes: All global indexes already USABLE.');
  end if;
  
end RebuildGlobalIndexes;
   