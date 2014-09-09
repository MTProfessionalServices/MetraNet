/*
===========================================================
  Describe billing groups by Namespace
===========================================================
*/
INSERT INTO t_billgroup_tmp (
  id_billgroup, id_materialization, tx_name, tx_description)
select 
  seq_t_billgroup_tmp.nextval, id_materialization, tx_name, description
from (
  SELECT DISTINCT 
    %%ID_MATERIALIZATION%% as id_materialization, 
    tx_name,
    tx_name || N' Bill Group' as description
  FROM t_billgroup_member_tmp
  WHERE id_materialization = %%ID_MATERIALIZATION%%
  order by tx_name
  ) subqry