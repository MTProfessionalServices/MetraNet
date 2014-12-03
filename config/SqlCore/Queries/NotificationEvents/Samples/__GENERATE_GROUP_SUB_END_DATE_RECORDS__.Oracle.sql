/*NOTE:Notifications will be generated only for subscriptions which end by (CURRENT_RUN_DATE + NOTIFICATION_DAYS) to the nearest second.
 So if NOTIFICATION_DAYS =10 and CURRENT_RUN_DATE = '05-NOV-2014 13:30:56' , then notifications will be generated for all the subscriptions
 with the vt_end before 15-NOV-2014 13:30:56*/
WITH 
constants AS ( SELECT 
    10 AS NOTIFICATION_DAYS /*Number of days before the subscription expires*/
    FROM DUAL
)
SELECT  
  gsubmember.id_acc AccountID,   
  CASE 
    WHEN tmap_for_partitioned_acc.nm_login IS NULL THEN tmap_for_nonpartitioned_acc.nm_login
    ELSE tmap_for_partitioned_acc.nm_login
  END LoginName,
  gsubmember.vt_end EndDate,  
  tbp.nm_name POInternalName,
  t_po.c_POPartitionId id_Partition
FROM constants, t_gsubmember gsubmember
  INNER JOIN t_sub sub ON gsubmember.id_group=sub.id_group
  INNER JOIN t_vw_base_props tbp ON sub.id_po = tbp.id_prop AND tbp.id_lang_code = :LANGUAGE_CODE
  INNER JOIN t_po ON sub.id_po = t_po.id_po
  LEFT OUTER JOIN t_account_mapper partition_owner ON partition_owner.id_acc = t_po.c_POPartitionId AND partition_owner.nm_space = 'mt' AND partition_owner.id_acc != 1
  /*now we will get the nm_login for the subscriber account*/
  LEFT OUTER JOIN t_account_mapper tmap_for_nonpartitioned_acc ON tmap_for_nonpartitioned_acc.id_acc = gsubmember.id_acc AND tmap_for_nonpartitioned_acc.nm_space = 'mt'
  LEFT OUTER JOIN t_account_mapper tmap_for_partitioned_acc ON tmap_for_partitioned_acc.id_acc = gsubmember.id_acc AND tmap_for_partitioned_acc.nm_space = LOWER (partition_owner.nm_login) 
  WHERE gsubmember.vt_end <= :CURRENT_RUN_DATE + constants.NOTIFICATION_DAYS 
  AND gsubmember.vt_end >= :LAST_RUN_DATE + constants.NOTIFICATION_DAYS 
  
