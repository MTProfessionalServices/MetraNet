
        select id_pt, nm_name, nm_desc, nm_display_name
        from t_pi_rulesetdef_map
        join t_vw_base_props on id_prop = id_pt
        where id_pi = %%ID_PI%% and t_vw_base_props.id_lang_code = %%ID_LANG%%
      