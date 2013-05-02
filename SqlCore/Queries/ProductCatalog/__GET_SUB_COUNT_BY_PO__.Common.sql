
      select count(t_sub.id_po)
      from t_sub
      where 
      %%%SYSTEMDATE%%% between t_sub.vt_start AND t_sub.vt_end AND
      t_sub.id_po =  %%ID_PO%%
    