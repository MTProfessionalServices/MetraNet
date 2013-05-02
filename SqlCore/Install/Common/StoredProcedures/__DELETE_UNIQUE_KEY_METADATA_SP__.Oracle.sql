
      /*
      	DeleteUniqueKeyMetadata

      	Deletes the metadata for a unique key.  Removes all
      	rows for a given unique key in the tables: t_unqiue_cons &
      	t_unique_cons_columns.

      	consname - name of unique key

      */
CREATE OR REPLACE
procedure DeleteUniqueKeyMetadata
(
  consname varchar2
)
as
begin

  /* Delete key colums first
    */
  delete from t_unique_cons_columns
  where id_unique_cons in (
    select id_unique_cons from t_unique_cons
    where lower(constraint_name) = lower(consname));

  /* Delete key name
    */
  delete from t_unique_cons
  where lower(constraint_name) = lower(consname);

end DeleteUniqueKeyMetadata;
 	