
        select
			bp.id_prop, 
			bp.n_kind,
			bp.n_name, 
			bp.n_desc, 
			bp.n_display_name,
			bp.nm_name, 
			bp.nm_desc, 
			bp.nm_display_name,
			rec.n_rating_type as n_rating_type
        from t_base_props bp
        join t_pl_map on bp.id_prop = t_pl_map.id_pi_instance
        left outer join t_recur rec on t_pl_map.id_pi_instance = rec.id_prop
        where id_po = %%ID_PO%% and id_pi_type = %%ID_PI%% 
				and id_pi_instance_parent is NULL and id_paramtable is NULL
      