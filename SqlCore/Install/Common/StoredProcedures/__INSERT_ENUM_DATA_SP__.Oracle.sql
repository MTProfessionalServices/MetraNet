
CREATE OR REPLACE
procedure insertenumdata (
   p_nm_enum_data   in       nvarchar2,
   p_id_enum_data   out      int
)
as
  /*pragma autonomous_transaction;*/
begin

  select seq_t_mt_id.nextval into p_id_enum_data from dual;

  insert into t_mt_id (id_mt)
    values (p_id_enum_data);

  insert into t_enum_data (id_enum_data, nm_enum_data)
    values (p_id_enum_data, p_nm_enum_data);

exception when dup_val_on_index then

  select id_enum_data into p_id_enum_data
    from t_enum_data
    where upper(nm_enum_data) = upper(p_nm_enum_data);

end insertenumdata;
