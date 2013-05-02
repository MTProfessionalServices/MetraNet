
          select
          id_paramtable, nm_name, nm_instance_tablename
          from t_rulesetdefinition inner join t_base_props on id_paramtable = id_prop
        