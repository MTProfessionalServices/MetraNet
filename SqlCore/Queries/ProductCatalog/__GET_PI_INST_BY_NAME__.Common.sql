
      select bp.id_prop, 
			bp.nm_name, 
			bp.nm_desc, 
			bp.nm_display_name, 
			bp.n_display_name, 
			bp.n_kind,
			t_pl_map.id_pi_type, 
			t_pl_map.id_pi_instance_parent as id_pi_parent, 
			t_pl_map.id_pi_template, 
			t_pl_map.id_po, bp.n_desc
      from t_base_props bp
      join t_pl_map on bp.id_prop = t_pl_map.id_pi_instance
      where %%%UPPER%%%(bp.nm_name) = %%%UPPER%%%('%%NAME%%')
      and t_pl_map.id_po = %%ID_PO%% and t_pl_map.id_paramtable is NULL
    