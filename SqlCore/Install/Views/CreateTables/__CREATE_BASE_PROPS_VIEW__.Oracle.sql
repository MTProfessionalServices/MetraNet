
create or replace force  view t_vw_base_props
as
select
  td_dispname.id_lang_code as id_lang_code, bp.id_prop, bp.n_kind, bp.n_name, bp.n_desc, 
  bp.nm_name as nm_name, td_desc.tx_desc as nm_desc, bp.b_approved, bp.b_archive,
  bp.n_display_name, td_dispname.tx_desc as nm_display_name
from t_base_props bp
  left join t_description td_dispname on td_dispname.id_desc = bp.n_display_name
  left join t_description td_desc on td_desc.id_desc = bp.n_desc and td_desc.id_lang_code = td_dispname.id_lang_code
  