 select 
      /* __GET_ADJUSTMENT_TEMPLATES_OR_INSTANCES__ */
      aj.id_prop,
      aj.id_adjustment_type,
			aj.id_pi_instance,
			aj.id_pi_template,
			aj.tx_guid,
			bp.nm_name,
			bp.n_display_name,
			bp.nm_display_name,
			bp.nm_desc,
			bp.n_desc
			FROM t_adjustment aj
			INNER JOIN t_base_props bp ON aj.id_prop=bp.id_prop
			WHERE
      %%PI_COLUMN%% = %%ID_PI%%