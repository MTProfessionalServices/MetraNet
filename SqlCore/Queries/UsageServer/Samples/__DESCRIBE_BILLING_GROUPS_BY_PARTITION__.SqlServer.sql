/*
===========================================================
  Describe billing groups by Partition
===========================================================
*/
INSERT INTO t_billgroup_tmp (id_materialization, tx_name, tx_description, id_partition)
SELECT DISTINCT 
  %%ID_MATERIALIZATION%%, 
  tx_name,
  concat(tx_name, N' Bill Group'),
  id_partition
FROM t_billgroup_member_tmp
WHERE id_materialization = %%ID_MATERIALIZATION%%
ORDER BY tx_name
