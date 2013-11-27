
/* ===========================================================
Returns the billing group id for the given account id and the given interval id.

BillingGroupID
=========================================================== */
SELECT bgm.id_billgroup BillingGroupID
FROM t_billgroup_member bgm
INNER JOIN t_billgroup bg
   ON bg.id_billgroup = bgm.id_billgroup
INNER JOIN vw_mps_or_system_acc_mapper av 
   ON av.id_acc = bgm.id_acc
WHERE av.nm_login = '%%USERNAME%%' AND
            av.nm_space = '%%NAMESPACE%%' AND
            bg.id_usage_interval = %%ID_INTERVAL%%
   