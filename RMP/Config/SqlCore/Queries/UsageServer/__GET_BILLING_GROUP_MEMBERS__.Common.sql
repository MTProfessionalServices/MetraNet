
/* ===========================================================
Returns the following from t_billgroup_member for the given billing group id
   DisplayName
   UserName
   Namespace
   AccountID
=========================================================== */
SELECT accMap.displayname DisplayName,
            accMap.nm_login UserName,
            accMap.nm_space Namespace,
            accMap.id_acc AccountID
FROM t_billgroup_member bgm
INNER JOIN vw_mps_or_system_acc_mapper accMap 
  ON accMap.id_acc = bgm.id_acc
WHERE id_billgroup = %%ID_BILLGROUP%%
ORDER BY accMap.displayname
   