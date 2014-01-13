
        select
        t_vw_base_props.id_prop, t_vw_base_props.n_kind,
        t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
        t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name,
        rec.n_rating_type as n_rating_type
        from t_vw_base_props
        join t_pl_map on t_vw_base_props.id_prop = t_pl_map.id_pi_instance and t_vw_base_props.id_lang_code = %%ID_LANG%%
        left outer join t_recur rec on t_pl_map.id_pi_instance = rec.id_prop
        where id_po = %%ID_PO%% and id_pi_instance_parent is NULL and id_paramtable is NULL
      