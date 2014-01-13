
/* ===========================================================
Returns a rowset with the unassigned accounts for the given interval.

accountId, 
displayName,
nm_space,
nm_login, 
status
=========================================================== */
SELECT ua.AccountID AccountId, 
            av.hierarchydisplayname DisplayName, 
            av.nm_login, 
            av.nm_space,
            ua.state Status
FROM vw_unassigned_accounts ua 
INNER JOIN vw_mps_or_system_acc_mapper av 
  ON ua.AccountID = av.id_acc 
%%WHERE_CLAUSE%%
%%ORDER_BY_CLAUSE%%
   