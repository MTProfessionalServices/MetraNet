
        select 
        id_template,
        COALESCE(tvp.n_kind, tbp.n_kind) n_kind,
        COALESCE(tvp.n_name, tbp.n_name) n_name,
        COALESCE(tvp.n_desc, tbp.n_desc) n_desc,
        COALESCE(tvp.n_display_name, tbp.n_display_name) n_display_name,
        COALESCE(tvp.nm_name, tbp.nm_name) nm_name,
        COALESCE(tvp.nm_desc, tbp.nm_desc) nm_desc,
        COALESCE(tvp.nm_display_name, tbp.nm_display_name) nm_display_name,
        CAST(NULL AS INT) n_rating_type 
        from t_pi_template tpt
        INNER JOIN t_base_props tbp ON tbp.id_prop = tpt.id_template
        LEFT JOIN t_vw_base_props tvp ON tvp.nm_name = tbp.nm_name AND tvp.id_lang_code = %%ID_LANG%%
        where id_template_parent = %%ID_PARENT%%
      