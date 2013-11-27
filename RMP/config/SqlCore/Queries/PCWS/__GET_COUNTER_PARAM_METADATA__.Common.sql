
				SELECT	cpm.id_prop id_prop
				FROM	t_counter_metadata cm 
				JOIN	t_base_props bp on bp.id_prop = cm.id_prop
				JOIN	t_counter_params_metadata cpm on cpm.id_counter_meta = cm.id_prop
				JOIN	t_base_props pbp on cpm.id_prop = pbp.id_prop
				WHERE	bp.id_prop = %%COUNTER_TYPE_ID%% 
				AND		pbp.nm_name = '%%COUNTER_PARAM_NAME%%'
		