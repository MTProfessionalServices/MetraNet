
/* ===========================================================
Returns a rowset with reassignment failures found during a rematerialization.

AccountID
DisplayName
UserName
Namespace
Description
=========================================================== */
SELECT accMap.id_acc AccountID,
            accMap.displayname DisplayName,
            accMap.nm_login UserName,
            accMap.nm_space Namespace,
            bgmh.tx_failure_reason Description
FROM t_billgroup_member_history bgmh
INNER JOIN vw_mps_acc_mapper accMap 
  ON accMap.id_acc = bgmh.id_acc
WHERE bgmh.id_materialization = %%ID_MATERIALIZATION%% AND  
            bgmh.tx_status = 'Failed'
ORDER BY accMap.displayname
   