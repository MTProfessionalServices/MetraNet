
        select 
          t_vw_base_props.id_prop,
          t_vw_base_props.n_name, t_vw_base_props.n_desc, t_vw_base_props.n_display_name,
          t_vw_base_props.nm_name, t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name,
          b_user_subscribe, b_user_unsubscribe, b_hidden, nm_currency_code, t_po.c_POPartitionId
          %%COLUMNS%%
        from t_vw_base_props
        join t_po on id_prop = id_po
        join t_pricelist on id_pricelist = id_nonshared_pl
        %%JOINS%%
        where t_vw_base_props.n_kind = 100 and t_vw_base_props.id_lang_code = %%ID_LANG%%
        %%FILTERS%%
      