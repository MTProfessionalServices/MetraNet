
        select DISTINCT(tm.id_po) from t_pl_map tm
          INNER JOIN t_sub ON t_sub.id_po = tm.id_po AND 
          t_sub.id_acc = %%ID_ACC%%
          where tm.id_pi_type in 
          (select id_pi_type from t_pl_map where id_po = %%ID_PO%%)
      