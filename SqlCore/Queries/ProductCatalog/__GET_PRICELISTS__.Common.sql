
        select
          t_vw_base_props.id_prop, t_vw_base_props.n_name,
          t_vw_base_props.n_desc, t_vw_base_props.nm_name,
          t_vw_base_props.nm_desc, t_vw_base_props.nm_display_name,
          t_pricelist.n_type, t_pricelist.nm_currency_code,
          tmp.rateschedules, t_pricelist.c_PLPartitionId
          from t_vw_base_props,
          t_pricelist
          LEFT OUTER JOIN 
              (select rs.id_pricelist, count(*) rateschedules
              from t_rsched rs %%RS_WHERE%%
              group by rs.id_pricelist) tmp
            on t_pricelist.id_pricelist = tmp.id_pricelist
          where t_pricelist.id_pricelist = t_vw_base_props.id_prop
          and t_vw_base_props.id_lang_code = %%ID_LANG%%
          AND %%FILTER%%
       