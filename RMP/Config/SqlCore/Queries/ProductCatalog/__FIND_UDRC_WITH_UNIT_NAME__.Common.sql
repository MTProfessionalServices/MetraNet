
	select r.id_prop, bp.nm_display_name from
	t_recur r
	inner join t_base_props bp on r.id_prop=bp.id_prop
	inner join t_pl_map pl on r.id_prop=pl.id_pi_instance 
	where
	pl.id_paramtable IS NULL 
	and pl.id_po=%%ID_PO%%
	and r.nm_unit_name = '%%NM_UNIT_NAME%%'
  