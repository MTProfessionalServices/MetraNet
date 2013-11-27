
create or replace force VIEW vw_all_billing_groups_status AS 
SELECT bgm.id_billgroup, aui.id_usage_interval, aui.tx_status status
FROM (SELECT bg.id_billgroup,
             bg.id_usage_interval,
             (SELECT id_acc
              FROM t_billgroup_member bgm1
              WHERE bgm1.id_billgroup = bg.id_billgroup AND ROWNUM <= 1)
              id_acc
     FROM t_billgroup bg) bgm,
     t_acc_usage_interval aui
WHERE bgm.id_usage_interval = aui.id_usage_interval
      AND bgm.id_acc = aui.id_acc
	