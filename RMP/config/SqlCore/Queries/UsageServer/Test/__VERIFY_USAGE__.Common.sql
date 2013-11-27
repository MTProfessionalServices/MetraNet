
/* ===========================================================
Return the max id_materialization id from t_billgroup_materialization.
============================================================== */
SELECT COUNT(id_sess) numUsage
FROM t_acc_usage au
INNER JOIN t_enum_data ed
  ON ed.id_enum_data = au.id_svc
WHERE au.id_payee = %%ID_ACC%% AND
      au.id_usage_interval = %%ID_INTERVAL%% AND
      %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%(N'metratech.com/testservice')
 