DECLARE @LAST_NOTIFY_FROM DateTime
DECLARE @MAX_SUB_END_DATE DateTime
DECLARE @NOTIFICATION_DAYS int

SET @NOTIFICATION_DAYS = 10 
SET @MAX_SUB_END_DATE = DATEADD(DAY, DATEDIFF(day, 0, GETDATE()), @NOTIFICATION_DAYS) + '23:59:59'
SET @LAST_NOTIFY_FROM = DATEADD(D, @NOTIFICATION_DAYS, @LAST_RUN_DATE) 

SELECT
'GROUP' varSubType, gsubmember.id_acc varAccount, gsubmember.vt_end varEndDate, gsub.tx_name varDisplayName
FROM t_gsubmember gsubmember
INNER JOIN t_group_sub gsub on gsubmember.id_group = gsub.id_group
INNER JOIN t_account_mapper map 
  ON map.id_acc = gsubmember.id_acc
WHERE gsubmember.vt_end <= @MAX_SUB_END_DATE 
AND gsubmember.vt_end >= @LAST_NOTIFY_FROM