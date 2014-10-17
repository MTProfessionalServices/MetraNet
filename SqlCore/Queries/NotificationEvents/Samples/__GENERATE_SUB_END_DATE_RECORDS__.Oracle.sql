DECLARE @LAST_NOTIFY_FROM DateTime
DECLARE @MAX_SUB_END_DATE DateTime
DECLARE @NOTIFICATION_DAYS int

SET @NOTIFICATION_DAYS = 10 
SET @MAX_SUB_END_DATE = DATEADD(DAY, DATEDIFF(day, 0, GETDATE()), @NOTIFICATION_DAYS) + '23:59:59'
SET @LAST_NOTIFY_FROM = DATEADD(D, @NOTIFICATION_DAYS, @LAST_RUN_DATE)

SELECT
'SUB' varSubType, map.nm_login, sub.id_acc varAccount, sub.vt_end varEndDate, tbp.nm_display_name varDisplayName
FROM t_sub sub
INNER JOIN t_vw_base_props tbp
	ON sub.id_po = tbp.id_prop 
	AND tbp.id_lang_code = @LANGUAGE_CODE
INNER JOIN t_account_mapper map 
  ON map.id_acc = sub.id_acc
WHERE sub.vt_end <= @MAX_SUB_END_DATE 
AND sub.vt_end >= @LAST_NOTIFY_FROM