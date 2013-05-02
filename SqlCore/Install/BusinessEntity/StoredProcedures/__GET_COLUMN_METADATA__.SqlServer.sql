
/* ===========================================================

=========================================================== */

create procedure GetColumnMetadata 
 @p_table_names nvarchar(max),
 @p_separator nvarchar(10)
as
begin

SELECT tbl.name TableName,
       col.name ColumnName,
       typ.name DbTypeName,
       case when lower(typ.name) = 'nvarchar'
            then col.max_length / 2
            else col.max_length
            end as MaxLength,
       col.precision Precision,
       col.scale Scale,
       col.is_nullable NullableFlag,
       case when i.is_primary_key is null 
            then 0 
            else i.is_primary_key 
            end as PrimaryKeyFlag,
       case when i.is_unique is null 
            then 0 
            else i.is_unique 
            end as UniqueFlag
from (select item from String2Table(@p_table_names, @p_separator)) inputTables
inner join sys.tables tbl 
  on tbl.name = inputTables.Item
inner join sys.columns col 
  on col.object_id = tbl.object_id
inner join sys.types typ
  on typ.user_type_id = col.user_type_id
left outer join sys.index_columns ic 
  on ic.object_id = col.object_id and 
     ic.column_id = col.column_id
left outer join sys.indexes i
  on i.object_id = ic.object_id and 
     i.index_id = ic.index_id         
where typ.name not in ('binary', 'varbinary', 'text', 'ntext', 'image')
      
end
		