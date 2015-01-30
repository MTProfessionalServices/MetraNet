
/* ===========================================================
Returns a rowset with the unassigned accounts for the given interval.

accountId, 
displayName,
nm_space,
nm_login, 
status,
PartitionId
=========================================================== */
SELECT ua.AccountID AccountId, 
            av.hierarchydisplayname DisplayName, 
            av.nm_login, 
            av.nm_space,
            ua.state Status,
            partition_root.id_acc PartitionId
FROM vw_unassigned_accounts ua 
INNER JOIN vw_mps_or_system_acc_mapper av 
  ON ua.AccountID = av.id_acc 
LEFT OUTER JOIN t_account_mapper tam on tam.id_acc = ua.AccountID
LEFT OUTER JOIN t_account_mapper partition_root on lower(partition_root.nm_login) = lower(tam.nm_space)
%%WHERE_CLAUSE%%
%%ORDER_BY_CLAUSE%%
   