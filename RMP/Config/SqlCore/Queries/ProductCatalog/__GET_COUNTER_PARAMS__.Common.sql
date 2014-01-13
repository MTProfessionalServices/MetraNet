
          SELECT 
            id_counter_param, Value, id_counter_param_meta, cpmbp.nm_name ParamName, 
            bp.nm_desc ParamDescription, bp.nm_display_name ParamDisplayName, ParamType, DBType
	          ,'F' IsShared
          FROM 
            t_counter_params cp, t_counter_params_metadata cpm, t_vw_base_props cpmbp,
            t_vw_base_props bp
          WHERE 
            cp.id_counter = %%ID_PROP%%
          AND            cp.id_counter_param_meta = cpm.id_prop
          AND
            cpm.id_prop = cpmbp.id_prop  and cpmbp.id_lang_code = %%ID_LANG%%
          AND
            id_counter_param = bp.id_prop  and bp.id_lang_code = %%ID_LANG%%

          /* UNION in the shared counter parameters */
          UNION ALL
          SELECT
            SharedMap.id_counter_param, Value, SharedMap.id_counter_param_meta,
            cpmbp.nm_name ParamName,
            bp.nm_desc ParamDescription, bp.nm_display_name ParamDisplayName,
            ParamType, DBType
            ,'T' IsShared
            FROM
            t_counter_param_map SharedMap
            INNER JOIN t_counter_params cp ON cp.id_counter_param = SharedMap.id_counter_param
            INNER JOIN t_counter_params_metadata cpm ON SharedMap.id_counter_param_meta = cpm.id_prop
            INNER JOIN t_vw_base_props cpmbp ON (cpm.id_prop = cpmbp.id_prop AND cpmbp.id_lang_code = %%ID_LANG%%)
            INNER JOIN t_vw_base_props bp ON (SharedMap.id_counter_param = bp.id_prop AND cpmbp.id_lang_code = %%ID_LANG%%)
            WHERE SharedMap.id_counter = %%ID_PROP%%
        