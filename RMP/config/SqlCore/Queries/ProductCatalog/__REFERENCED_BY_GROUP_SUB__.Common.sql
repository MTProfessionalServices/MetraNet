
    select count(t_sub.id_sub) subcount
    from t_sub
    INNER JOIN t_pl_map map on map.id_pi_template = %%ID_TEMPLATE%% AND
      map.id_paramtable = %%ID_PARAMTABLE%% AND map.id_pricelist = %%ID_PL%%
    where
    t_sub.id_po = map.id_po and id_group is not NULL
    