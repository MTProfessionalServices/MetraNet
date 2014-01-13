
/* ===========================================================
Returns the extra accounts (if any) which were added during pull list creation
for the given id_materialization

DisplayName
UserName
Namespace
AccountID

Sort on:  DisplayName ASC
=========================================================== */
SELECT accMap.displayname DisplayName,
            accMap.nm_login UserName,
            accMap.nm_space Namespace,
            accMap.id_acc AccountID 
FROM t_billgroup_member_tmp bgmt
INNER JOIN vw_mps_or_system_acc_mapper accMap 
  ON accMap.id_acc = bgmt.id_acc
WHERE bgmt.id_materialization =  %%ID_MATERIALIZATION%% AND
           bgmt.b_extra = 1
ORDER BY accMap.displayname
   