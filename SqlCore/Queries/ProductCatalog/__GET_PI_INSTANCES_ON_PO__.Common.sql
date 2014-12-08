      SELECT
        COALESCE(tvp.id_prop, tbp.id_prop) id_prop,
        COALESCE(tvp.n_kind, tbp.n_kind) n_kind,
        COALESCE(tvp.n_name, tbp.n_name) n_name,
        COALESCE(tvp.n_desc, tbp.n_desc) n_desc,
        COALESCE(tvp.n_display_name, tbp.n_display_name) n_display_name,
        COALESCE(tvp.nm_name, tbp.nm_name) nm_name,
        COALESCE(tvp.nm_desc, tbp.nm_desc) nm_desc,
        COALESCE(tvp.nm_display_name, tbp.nm_display_name) nm_display_name,
        rec.n_rating_type as n_rating_type
      FROM t_pl_map tpl 
        INNER JOIN t_base_props tbp ON tbp.id_prop = tpl.id_pi_instance
        LEFT OUTER JOIN t_vw_base_props tvp ON tvp.id_prop = tbp.id_prop AND tvp.id_lang_code = %%ID_LANG%%
        LEFT OUTER JOIN t_recur rec ON rec.id_prop = tpl.id_pi_instance
      WHERE tpl.id_po = %%ID_PO%% AND tpl.id_pi_instance_parent IS NULL AND tpl.id_paramtable IS NULL
