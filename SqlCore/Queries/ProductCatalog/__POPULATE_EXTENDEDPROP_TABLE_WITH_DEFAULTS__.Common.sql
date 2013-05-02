
        insert into %%EP_TABLE%% (id_prop %%EP_COLUMNLIST%%) 
        select t_base_props.id_prop %%DEFAULTS_VALUES%% from t_base_props where n_kind = %%KIND%%
        UNION
        select t_base_props.id_prop %%DEFAULTS_VALUES%% from t_pl_map,t_base_props where t_base_props.n_kind = %%KIND%% 
        and t_base_props.id_prop = t_pl_map.id_pi_instance AND
        t_pl_map.id_paramtable is NULL
      