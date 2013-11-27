
        SELECT  
          c.id_prop, id_counter_type,  nm_name, nm_desc 
        FROM 
          t_counter c, t_vw_base_props bp 
        WHERE 
          c.id_prop = bp.id_prop and bp.id_lang_code = %%ID_LANG%%
      