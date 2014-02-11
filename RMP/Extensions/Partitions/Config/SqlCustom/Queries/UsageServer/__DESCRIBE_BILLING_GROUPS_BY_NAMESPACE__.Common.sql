/*
===========================================================
  Describe billing groups by Namespace
===========================================================
*/
INSERT INTO t_billgroup_tmp (id_materialization, tx_name, tx_description)
SELECT DISTINCT 
  %%ID_MATERIALIZATION%%, 
  tx_name,
  tx_name + N' Bill Group'
FROM t_billgroup_member_tmp
WHERE id_materialization = %%ID_MATERIALIZATION%%
ORDER BY tx_name
