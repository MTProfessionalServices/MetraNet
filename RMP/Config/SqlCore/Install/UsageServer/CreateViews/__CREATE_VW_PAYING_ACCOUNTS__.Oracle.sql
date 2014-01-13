
/* ===========================================================
Return the paying accounts for each interval
=========================================================== */
create or replace force VIEW vw_paying_accounts AS
   SELECT aui.id_usage_interval IntervalID,
          aui.id_acc AccountID,
          aui.tx_status State
   FROM t_acc_usage_interval aui
   INNER JOIN t_account_mapper amap ON amap.id_acc = aui.id_acc
   INNER JOIN t_namespace nmspace ON nmspace.nm_space = amap.nm_space
   WHERE  nmspace.tx_typ_space = 'system_mps' 
   GROUP BY aui.id_usage_interval, aui.id_acc, aui.tx_status
   