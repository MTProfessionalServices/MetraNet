
        select id_pi_instance, t_vw_base_props.n_kind,
        t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
        t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name,
        rec.n_rating_type as n_rating_type
        from t_pl_map
        join t_vw_base_props on t_vw_base_props.id_prop = id_pi_instance and t_vw_base_props.id_lang_code = %%ID_LANG%%
        left outer join t_recur rec on t_pl_map.id_pi_instance = rec.id_prop
        where id_pi_instance_parent = %%ID_PARENT%% and id_paramtable is NULL
      