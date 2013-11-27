
      select gsub.id_group, gsub.tx_name
      from t_sub sub
      join t_group_sub gsub on sub.id_group = gsub.id_group
      join t_usage_cycle uc on gsub.id_usage_cycle = uc.id_usage_cycle
      where 
      %%%SYSTEMDATE%%% < sub.vt_end
      AND sub.id_po = %%ID_PO%%
      AND uc.id_cycle_type <> %%CYCLE_TYPE%%
    