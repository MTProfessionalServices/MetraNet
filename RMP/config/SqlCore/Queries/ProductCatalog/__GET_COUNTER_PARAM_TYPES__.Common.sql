
        SELECT  
          cpm.id_prop, nm_name, ParamType, DBType 
        FROM 
          t_counter_params_metadata cpm, t_counter_metadata ct, t_vw_base_props bp 
        WHERE 
          cpm.id_prop = bp.id_prop and bp.id_lang_code = %%ID_LANG%%
        AND 
          cpm.id_counter_meta = ct.id_prop 
        AND 
          cpm.id_counter_meta = %%ID_PROP%%
      