/*NOTE:Notifications will be generated only for subscriptions which end by (CURRENT_RUN_DATE + NOTIFICATION_DAYS) to the nearest second.
 So if NOTIFICATION_DAYS =10 and CURRENT_RUN_DATE = '05-NOV-2014 13:30:56' , then notifications will be generated for all the subscriptions
 with the vt_end before 15-NOV-2014 13:30:56*/
DECLARE @NOTIFICATION_DAYS int
DECLARE @LAST_NOTIFY_FROM DateTime
DECLARE @MAX_SUB_END_DATE DateTime

SET @NOTIFICATION_DAYS = 10 /*Number of days before the subscription expires*/
SET @MAX_SUB_END_DATE = DATEADD(D, @NOTIFICATION_DAYS, @CURRENT_RUN_DATE) 
SET @LAST_NOTIFY_FROM = DATEADD(D, @NOTIFICATION_DAYS, @LAST_RUN_DATE) 

SELECT
  'GROUPSUB' varSubType,
  gsubmember.id_acc varAccount,
  varLoginName = 
  CASE 
    WHEN tmap_for_partitioned_account.nm_login IS NULL THEN tmap_for_nonpartitioned_account.nm_login
    ELSE tmap_for_partitioned_account.nm_login
  END,
  gsubmember.vt_end varEndDate,
  sub.id_po varPOID,
  tbp.nm_name varPOInternalName,
  t_po.c_POPartitionId id_Partition
FROM t_gsubmember gsubmember
  INNER JOIN t_sub sub ON gsubmember.id_group=sub.id_group
  INNER JOIN t_vw_base_props tbp ON sub.id_po = tbp.id_prop AND tbp.id_lang_code = @LANGUAGE_CODE
  INNER JOIN t_po ON sub.id_po = t_po.id_po
  LEFT OUTER JOIN t_account_mapper partition_owner ON partition_owner.id_acc = t_po.c_POPartitionId and partition_owner.nm_space = 'mt' and partition_owner.id_acc != 1
  /*now we will get the nm_login for the subscriber account*/
  LEFT OUTER JOIN t_account_mapper tmap_for_nonpartitioned_account ON tmap_for_nonpartitioned_account.id_acc = gsubmember.id_acc and tmap_for_nonpartitioned_account.nm_space = 'mt'
  LEFT OUTER JOIN t_account_mapper tmap_for_partitioned_account ON tmap_for_partitioned_account.id_acc = gsubmember.id_acc and tmap_for_partitioned_account.nm_space = LOWER (partition_owner.nm_login)  
WHERE gsubmember.vt_end <= @MAX_SUB_END_DATE 
  AND gsubmember.vt_end > @LAST_NOTIFY_FROM