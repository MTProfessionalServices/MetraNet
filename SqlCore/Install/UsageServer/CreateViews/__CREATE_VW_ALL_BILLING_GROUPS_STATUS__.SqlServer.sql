
-- ===========================================================
-- Create a VIEW [on t_acc_usage_interval, t_billgroup_member and t_billgroup] which specifies
-- the following for each interval which has billing groups :

-- id_billgroup
-- id_usage_interval
-- status of the billing group ('O', 'C', or 'H')
-- ===========================================================
CREATE VIEW vw_all_billing_groups_status AS 
SELECT bgm.id_billgroup, aui.id_usage_interval, aui.tx_status status
FROM (SELECT bg.id_billgroup,
             bg.id_usage_interval,
             /* ESR-2909 performance modifications use "top 1" to emulate ORACLE "ROWNUM" changes done in 5.1.2 */ 
             (SELECT TOP 1 id_acc
              FROM t_billgroup_member bgm1
              WHERE bgm1.id_billgroup = bg.id_billgroup)
              id_acc
     FROM t_billgroup bg) bgm,
     t_acc_usage_interval aui
WHERE bgm.id_usage_interval = aui.id_usage_interval
      AND bgm.id_acc = aui.id_acc
	