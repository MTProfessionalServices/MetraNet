
        select t_pricelist.id_pricelist, t_pricelist.n_type, t_pricelist.nm_currency_code,
          t_base_props.nm_name, t_base_props.nm_desc, t_pricelist.c_PLPartitionId
        from t_av_internal
        join t_pricelist on t_pricelist.id_pricelist = t_av_internal.c_pricelist
        join t_base_props on t_base_props.id_prop = t_pricelist.id_pricelist
        where t_av_internal.id_acc = %%ACC_ID%%
      