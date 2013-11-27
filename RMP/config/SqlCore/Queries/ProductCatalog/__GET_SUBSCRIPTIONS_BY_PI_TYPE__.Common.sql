
        select 
        DISTINCT(map.id_po),
        t_sub.id_sub, t_sub.id_acc,t_sub.vt_start,t_sub.vt_end
        from t_sub
        INNER JOIN t_pl_map map on map.id_po = t_sub.id_po AND map.id_pi_type = %%ID_PI_TYPE%%
        where t_sub.id_acc = %%ID_ACC%%
      