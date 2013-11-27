
/* =========================================================
  Returns the row from t_billgroup_materialization for the given ID_MATERIALIZATION

MaterializationID
AccountID
DisplayName
UserName
Namespace
StartDate
EndDate
ParentBillingGroupID
IntervalID
MaterializationStatus
FailureReason
MaterializationType 

===========================================================*/
SELECT bm.id_materialization MaterializationID,
            accMap.id_acc AccountID,
            accMap.displayname DisplayName,
            accMap.nm_login UserName,
            accMap.nm_space Namespace, 
            bm.dt_start StartDate,
            bm.dt_end EndDate,
            bm.id_parent_billgroup ParentBillingGroupID,
            bm.id_usage_interval IntervalID,
            bm.tx_status MaterializationStatus,
            bm.tx_failure_reason FailureReason,
            bm.tx_type MaterializationType
FROM t_billgroup_materialization bm
INNER JOIN vw_mps_acc_mapper accMap 
   ON accMap.id_acc = bm.id_user_acc
WHERE bm.id_materialization = %%ID_MATERIALIZATION%%
   