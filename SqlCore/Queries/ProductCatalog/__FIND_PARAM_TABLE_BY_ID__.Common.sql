
          select id_paramtable,nm_instance_tablename, n_name, n_desc, nm_name, nm_desc 
            from t_rulesetdefinition 
            JOIN t_vw_base_props on t_vw_base_props.id_prop = t_rulesetdefinition.id_paramtable
             where t_vw_base_props.n_kind = 140 and t_vw_base_props.id_lang_code = %%ID_LANG%%
             and t_rulesetdefinition.id_paramtable=%%ID%%
      