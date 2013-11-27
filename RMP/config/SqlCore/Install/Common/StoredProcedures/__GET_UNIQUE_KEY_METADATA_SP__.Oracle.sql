
			/*
				Proc: GetUniqueKeyMetadata

				Returns unique key columns for all unique keys defined on a table.

				tabname - table name
			*/
create or replace procedure GetUniqueKeyMetadata
(
  tabname varchar2,
  p_cur out sys_refcursor
)
as
begin

  open p_cur for
    select
        uc.constraint_name,
        ucc.position as ordinal_position,
        pvp.nm_column_name as column_name
    from t_prod_view pv
    join t_unique_cons uc
      on pv.id_prod_view = uc.id_prod_view
    join t_unique_cons_columns ucc
      on uc.id_unique_cons = ucc.id_unique_cons
    join t_prod_view_prop pvp
      on ucc.id_prod_view_prop = pvp.id_prod_view_prop
    where pv.nm_table_name = tabname
    order by constraint_name, ordinal_position, column_name;

end GetUniqueKeyMetadata;
 	