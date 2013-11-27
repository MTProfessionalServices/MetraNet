
        select t_pricelist.id_pricelist, t_pricelist.n_type, t_pricelist.nm_currency_code,
        t_vw_base_props.nm_name, t_vw_base_props.nm_desc
        from t_pricelist
        join t_vw_base_props on t_vw_base_props.id_prop = t_pricelist.id_pricelist and t_vw_base_props.id_lang_code = %%ID_LANG%%
        where %%%UPPER%%%(t_vw_base_props.nm_name) = %%%UPPER%%%('%%NAME%%')
      