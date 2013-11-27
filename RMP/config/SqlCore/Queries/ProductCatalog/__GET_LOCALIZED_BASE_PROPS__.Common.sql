
        select
        nm_name,
        nm_display_name,
        nm_desc,
        n_kind
        from t_vw_base_props 
        where 
        id_prop = %%ID_PROP%% and id_lang_code = %%ID_LANG%% 
      