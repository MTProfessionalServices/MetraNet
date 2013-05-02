
SELECT COUNT(DISTINCT t_sub.id_acc)
FROM t_sub
INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = t_sub.id_acc
INNER JOIN t_usage_cycle uc ON auc.id_usage_cycle = uc.id_usage_cycle
WHERE 
  %%%SYSTEMDATE%%% < t_sub.vt_end AND
  t_sub.id_po = %%ID_PO%% AND
  %%CYCLE_TYPE_FILTER%%
    