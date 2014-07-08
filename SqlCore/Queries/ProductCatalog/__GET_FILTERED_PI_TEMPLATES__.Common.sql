
        select 
          t_vw_base_props.id_prop, t_vw_base_props.n_kind,
          t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
          t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name,
       	  (select count(*) from t_pi_template where t_pi_template.id_template_parent = t_vw_base_props.id_prop) NumberChildren,
       	  rec.n_rating_type
          %%COLUMNS%%
        from t_vw_base_props
        join t_pi_template on t_vw_base_props.id_prop = t_pi_template.id_template
        left join t_recur rec on t_vw_base_props.id_prop = rec.id_prop 
        %%JOINS%%
        where id_template_parent is NULL %%FILTERS%%
        and t_vw_base_props.id_lang_code = %%ID_LANG%%
      