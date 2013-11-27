
/* ===========================================================
Returns the billing group id for the given account id and the given interval id.

BillingGroupID
=========================================================== */
SELECT bgm.id_billgroup BillingGroupID
FROM t_billgroup_member bgm
INNER JOIN t_billgroup bg
   ON bg.id_billgroup = bgm.id_billgroup
WHERE bgm.id_acc = %%ID_ACCOUNT%% AND
      bg.id_usage_interval = %%ID_INTERVAL%%
   