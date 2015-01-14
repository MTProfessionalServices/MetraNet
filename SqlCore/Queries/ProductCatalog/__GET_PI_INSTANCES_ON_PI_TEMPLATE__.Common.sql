
        SELECT 
				bp.id_prop, 
				bp.n_kind,
				bp.n_name, 
				bp.n_desc, 
				bp.n_display_name,
				bp.nm_name,
				bp.nm_desc, 
				bp.nm_display_name
        FROM t_base_props bp, t_pl_map map
        WHERE map.id_pi_template = %%ID_PI_TEMPLATE%% AND
          bp.id_prop = map.id_pi_instance AND id_paramtable is NULL
      