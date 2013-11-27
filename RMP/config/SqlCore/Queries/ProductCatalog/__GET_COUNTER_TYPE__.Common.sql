
        SELECT  
          ct.id_prop, nm_name, nm_desc, FormulaTemplate, b_valid_for_dist 
        FROM 
          t_counter_metadata ct, t_vw_base_props bp 
        WHERE 
          ct.id_prop = bp.id_prop and bp.id_lang_code = %%ID_LANG%%
          AND 
          ct.id_prop = %%ID_PROP%%
      