
-- ===========================================================
-- Create a VIEW [on t_acc_usage_interval, t_billgroup_member and t_billgroup] which specifies
-- the following for each interval which has billing groups :

-- the total number of billing groups
-- the number of open billing groups
-- the number of soft closed billing groups
-- the number of hard closed billing groups
-- ===========================================================
CREATE VIEW vw_interval_billgroup_counts AS 
SELECT id_usage_interval, 
            SUM(CASE WHEN bgs.status = 'O' OR bgs.status = 'C' OR bgs.status = 'H' 
                             THEN 1 ELSE 0 END) TotalGroupCount,

            SUM(CASE WHEN bgs.status = 'O' THEN 1 ELSE 0 END) OpenGroupCount,
            SUM(CASE WHEN bgs.status = 'C' THEN 1 ELSE 0 END) SoftClosedGroupCount,
            SUM(CASE WHEN bgs.status = 'H' THEN 1 ELSE 0 END) HardClosedGroupCount
FROM vw_all_billing_groups_status bgs
GROUP BY id_usage_interval
	