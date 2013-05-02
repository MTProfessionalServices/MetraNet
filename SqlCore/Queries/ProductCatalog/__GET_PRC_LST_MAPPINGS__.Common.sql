
        select
        id_paramtable, tpt.nm_name as tpt_nm_name,
        id_pricelist, tpl.nm_name as tpl_nm_name,
        b_canICB, tpt.nm_display_name,
        rec.n_rating_type as n_rating_type
        from t_pl_map
        join t_vw_base_props tpt on tpt.id_prop = t_pl_map.id_paramtable and tpt.id_lang_code = %%ID_LANG%%
        left outer join t_recur rec on t_pl_map.id_pi_instance = rec.id_prop
        left outer join t_vw_base_props tpl on tpl.id_prop = t_pl_map.id_pricelist and tpl.id_lang_code = %%ID_LANG%%
        where id_pi_instance = %%ID_PI%%
      