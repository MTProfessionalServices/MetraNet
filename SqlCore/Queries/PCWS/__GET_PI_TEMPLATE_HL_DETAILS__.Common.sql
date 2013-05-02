
		        select 
	            bp.id_prop ID,
	            bp.nm_name Name,
	            bp.nm_display_name DisplayName,
	            bp.nm_desc Description,
	            pit.id_pi PIType,
				      bp2.nm_name PITypeName,
	            bp.n_kind PIKind
            from 
			      t_pi_template pit
            inner join t_base_props bp on pit.id_template = bp.id_prop
			      inner join t_base_props bp2 on pit.id_pi = bp2.id_prop
		    