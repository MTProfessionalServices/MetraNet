
/* ===========================================================
Get accounts from t_acc_usage based on id_view
============================================================== */
SELECT id_acc, amount 
FROM t_acc_usage au
INNER JOIN t_enum_data accountCredit 
  ON accountCredit.id_enum_data = au.id_view
WHERE %%%UPPER%%%(accountCredit.nm_enum_data) = %%%UPPER%%%(N'metratech.com/ARAdjustment') AND
      au.id_usage_interval = %%ID_INTERVAL%%
 