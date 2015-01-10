
        select
        t_vw_base_props.id_prop,
        t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
        t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name
        %%COLUMNS%%
        from t_vw_base_props
        join t_pi on t_vw_base_props.id_prop = t_pi.id_pi and t_vw_base_props.id_lang_code = %%ID_LANG%%
        %%JOINS%%
        where 1=1
        %%FILTERS%% order by t_vw_base_props.nm_name asc
      