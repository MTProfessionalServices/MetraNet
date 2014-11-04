WITH 
constants AS ( SELECT 
    10 AS NOTIFICATION_DAYS, /*Number of days before the subscription expires*/
    90 AS SUBSCRIPTION_WINDOW /*Number of days between the date of subscription creation/update and its expiration*/
    FROM DUAL
)
SELECT
  'SUB' varSubType,
  sub.id_acc varAccount,  
  CASE 
    WHEN tmap_for_partitioned_acc.nm_login IS NULL THEN tmap_for_nonpartitioned_acc.nm_login
    ELSE tmap_for_partitioned_acc.nm_login
  END varLoginName,
  sub.vt_end varEndDate,
  sub.id_po varPOID,
  tbp.nm_name varPOInternalName,
  t_po.c_POPartitionId id_Partition
FROM constants, t_sub sub
  INNER JOIN t_vw_base_props tbp ON sub.id_po = tbp.id_prop AND tbp.id_lang_code = :LANGUAGE_CODE
  INNER JOIN t_po ON sub.id_po = t_po.id_po
  INNER JOIN t_sub_history tsh ON sub.id_sub = tsh.id_sub AND sub.vt_end = tsh.vt_end
  LEFT OUTER JOIN t_account_mapper partition_owner ON partition_owner.id_acc = t_po.c_POPartitionId AND partition_owner.nm_space = 'mt' AND partition_owner.id_acc != 1
  /*now we will get the nm_login for the subscriber account*/
  LEFT OUTER JOIN t_account_mapper tmap_for_nonpartitioned_acc ON tmap_for_nonpartitioned_acc.id_acc = sub.id_acc AND tmap_for_nonpartitioned_acc.nm_space = 'mt'
  LEFT OUTER JOIN t_account_mapper tmap_for_partitioned_acc ON tmap_for_partitioned_acc.id_acc = sub.id_acc AND tmap_for_partitioned_acc.nm_space = LOWER (partition_owner.nm_login)  
WHERE sub.vt_end <= :CURRENT_RUN_DATE + constants.NOTIFICATION_DAYS
  AND sub.vt_end >= :LAST_RUN_DATE + constants.NOTIFICATION_DAYS
  AND sub.id_group IS NULL
   /* if the end date for the subscription was set within SUBSCRIPTION_WINDOW, then don’t warn about it */
  AND tsh.dt_crt <= sub.vt_end - constants.SUBSCRIPTION_WINDOW    
UNION
SELECT sq.varSubType, sq.varAccount, sq.varLoginName,sq.varEndDate, sq.varPOID, sq.varPOInternalName, sq.id_Partition
FROM(
       SELECT
         'SUB' varSubType,
         sub.id_acc varAccount,         
         CASE 
          WHEN tmap_for_partitioned_acc.nm_login IS NULL THEN tmap_for_nonpartitioned_acc.nm_login
          ELSE tmap_for_partitioned_acc.nm_login
         END varLoginName,
         sub.vt_end varEndDate,
         sub.id_po varPOID,
         tbp.nm_name varPOInternalName,
         t_po.c_POPartitionId id_Partition
       FROM constants, t_sub sub
         INNER JOIN t_po ON sub.id_po = t_po.id_po
         LEFT OUTER JOIN t_account_mapper partition_owner ON partition_owner.id_acc = t_po.c_POPartitionId AND partition_owner.nm_space = 'mt' AND partition_owner.id_acc != 1
         /*now we will get the nm_login for the subscriber account*/
         LEFT OUTER JOIN t_account_mapper tmap_for_nonpartitioned_acc ON tmap_for_nonpartitioned_acc.id_acc = sub.id_acc AND tmap_for_nonpartitioned_acc.nm_space = 'mt'
         LEFT OUTER JOIN t_account_mapper tmap_for_partitioned_acc ON tmap_for_partitioned_acc.id_acc = sub.id_acc AND tmap_for_partitioned_acc.nm_space = LOWER (partition_owner.nm_login)  
         INNER JOIN t_sub_history tsh ON sub.id_sub = tsh.id_sub AND sub.vt_end = tsh.vt_end
         INNER JOIN t_sub_history tsh2 ON sub.id_sub = tsh2.id_sub
         INNER JOIN t_vw_base_props tbp ON sub.id_po = tbp.id_prop AND tbp.id_lang_code = :LANGUAGE_CODE
       WHERE sub.vt_end <= :LAST_RUN_DATE + constants.NOTIFICATION_DAYS
         AND sub.vt_end > :CURRENT_RUN_DATE
         AND sub.id_group IS NULL 
         AND tsh.dt_crt <= :LAST_RUN_DATE + constants.NOTIFICATION_DAYS
          /* if the end date for the subscription was set within SUBSCRIPTION_WINDOW, then don’t warn about it */
         AND tsh.dt_crt <= sub.vt_end - constants.SUBSCRIPTION_WINDOW
         AND tsh.dt_crt >= :LAST_RUN_DATE         
         AND CAST(tsh2.dt_crt AS DATE) <= CAST(tsh.dt_crt AS DATE)  
         AND tsh2.vt_end > :CURRENT_RUN_DATE + constants.NOTIFICATION_DAYS
         AND tsh2.vt_end <> tsh.vt_end) sq         
GROUP BY sq.varSubType, sq.varAccount, sq.varLoginName, sq.varEndDate, sq.varPOID, sq.varPOInternalName, sq.id_Partition