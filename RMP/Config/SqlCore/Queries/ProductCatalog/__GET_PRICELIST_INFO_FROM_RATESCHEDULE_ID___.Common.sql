
    select rs.id_pricelist, bp.nm_name from t_rsched rs
    inner join t_base_props bp on rs.id_pricelist = bp.id_prop
    where rs.id_sched = %%ID_SCHED%%
  