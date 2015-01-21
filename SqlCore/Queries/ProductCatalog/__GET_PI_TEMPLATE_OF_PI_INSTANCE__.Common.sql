        
        SELECT 
          bp.id_prop
          ,bp.n_kind
          ,bp.n_name
          ,bp.n_desc
          ,bp.n_display_name
          ,bp.nm_name
          ,COALESCE(tvbp.nm_desc, bp.nm_desc) nm_desc
          ,COALESCE(tvbp.nm_display_name, bp.nm_display_name) nm_display_name
        FROM t_base_props bp
        JOIN t_pl_map on bp.id_prop = t_pl_map.id_pi_template
        LEFT OUTER JOIN t_vw_base_props tvbp ON tvbp.id_prop = bp.id_prop AND tvbp.id_lang_code = %%ID_LANG%%
        WHERE id_pi_instance = %%ID_PI_INSTANCE%% AND id_paramtable IS NULL
  