
				select 
					id_pi, 
					id_parent, 
					nm_servicedef, 
					nm_productview, 
					b_constrain_cycle,
					bp.n_name, 
					bp.n_desc, 
					bp.n_display_name,
					bp.nm_name, 
					COALESCE(vbp.nm_desc, bp.nm_desc) as nm_desc,
					COALESCE(vbp.nm_display_name, bp.nm_display_name) as nm_display_name,	
					bp.n_kind
				FROM t_pi
				JOIN t_base_props bp on bp.id_prop = t_pi.id_pi	  
				LEFT OUTER JOIN t_vw_base_props vbp ON (bp.id_prop = vbp.id_prop and vbp.id_lang_code = %%ID_LANG%%)
				WHERE vbp.nm_name = '%%NAME%%'
			