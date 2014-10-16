/*
===========================================================
  Describe billing groups by Partition
===========================================================
*/
INSERT INTO t_billgroup_tmp (
  id_billgroup, id_materialization, tx_name, tx_description, id_partition)
select 
  seq_t_billgroup_tmp.nextval, id_materialization, tx_name, description, id_partition
from (
  SELECT DISTINCT 
    %%ID_MATERIALIZATION%% as id_materialization, 
    tx_name,
    concat(tx_name, N' Bill Group') as description,
    id_partition
  FROM t_billgroup_member_tmp
  WHERE id_materialization = %%ID_MATERIALIZATION%%
  order by tx_name
  ) subqry