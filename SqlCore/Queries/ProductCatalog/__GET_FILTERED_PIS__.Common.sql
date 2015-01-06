
        select
        COALESCE(t_vw_base_props.id_prop, tbp.id_prop) id_prop,
        COALESCE(t_vw_base_props.n_name, tbp.n_name) n_name, 
        COALESCE(t_vw_base_props.n_desc, tbp.n_desc) n_desc, 
        COALESCE(t_vw_base_props.n_display_name, tbp.n_display_name) n_display_name,
        COALESCE(t_vw_base_props.nm_name, tbp.nm_name) nm_name,
        COALESCE(t_vw_base_props.nm_desc, tbp.nm_desc) nm_desc,
        COALESCE(t_vw_base_props.nm_display_name, tbp.nm_display_name) nm_display_name
        %%COLUMNS%%
        from t_pi        
        inner join t_base_props tbp on tbp.id_prop = t_pi.id_pi 
        left outer join t_vw_base_props on t_vw_base_props.id_prop = t_pi.id_pi and t_vw_base_props.id_lang_code = %%ID_LANG%%
        
        %%JOINS%%
        where 1=1
        %%FILTERS%% order by t_vw_base_props.nm_name asc
      
      
          