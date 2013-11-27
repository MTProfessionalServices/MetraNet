
/* ===========================================================
The input string (p_table_names) is a list of table names separated by p_separator
Split the input string into a table using the specified separator. 
Return a row of metadata for each table.

Input:
p_table_names     : List of table names separated by p_separator
p_separator       : Separator for p_table_names
=========================================================== */
create or replace procedure GetColumnMetadata(
  rows out sys_refcursor,
  p_table_names clob,
  p_separator varchar2)
as
begin
open rows for
select cols.table_name TableName,
       cols.column_name ColumnName,
       cols.data_type DbTypeName,
       cols.data_length MaxLength,
       cols.data_precision Precision,
       cols.data_scale Scale,
       case when cols.nullable = 'N'
            then 0 
            else 1 
            end as NullableFlag,
       case when pkeys.constraint_type = 'P'
            then 1 
            else 0 
            end as PrimaryKeyFlag,
       case when pkeys.constraint_type = 'Q'
            then 1 
            else 0 
            end as UniqueFlag
from table(cast(dbo.String2Table(p_table_names, p_separator) as  str_tab)) args
inner join user_tab_columns cols
  on cols.table_name = upper(args.COLUMN_VALUE)
left outer join 
  (select conscol.column_name, 
          conscol.table_name, 
          cons.constraint_type 
   from user_constraints cons
   inner join user_cons_columns conscol
     on conscol.constraint_name = cons.constraint_name
   where cons.constraint_type in ('P','U')) pkeys 
      on pkeys.column_name = cols.column_name and
         pkeys.table_name = cols.table_name
where cols.data_type not in ('BFILE', 'BLOB');
end;
			