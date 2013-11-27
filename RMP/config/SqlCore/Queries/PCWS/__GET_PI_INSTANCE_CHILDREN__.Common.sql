
               select id_pi_instance PI_ID, bp.nm_name PropertyName from t_pl_map map
               inner join t_base_props bp on map.id_pi_instance = bp.id_prop
               inner join t_base_props piTypeBP on map.id_pi_type = piTypeBP.id_prop
               where id_pi_instance_parent = %%PI_ID%%  and id_po = %%PO_ID%%
               and map.id_paramtable is NULL
               