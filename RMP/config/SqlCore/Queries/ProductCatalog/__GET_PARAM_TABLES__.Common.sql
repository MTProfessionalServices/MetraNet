
        SELECT id_paramtable,nm_instance_tablename, n_name, n_desc, nm_name, nm_desc
          FROM t_rulesetdefinition,t_vw_base_props
          WHERE t_vw_base_props.id_prop = t_rulesetdefinition.id_paramtable
          and t_vw_base_props.n_kind = 140 and t_vw_base_props.id_lang_code = %%ID_LANG%%
      