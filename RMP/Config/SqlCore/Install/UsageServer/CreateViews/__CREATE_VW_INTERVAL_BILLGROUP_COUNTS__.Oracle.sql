
create or replace force VIEW vw_interval_billgroup_counts AS 
SELECT id_usage_interval, 
            SUM(CASE WHEN bgs.status = 'O' OR bgs.status = 'C' OR bgs.status = 'H' 
                             THEN 1 ELSE 0 END) as TotalGroupCount,
            SUM(CASE WHEN bgs.status = 'O' THEN 1 ELSE 0 END) as OpenGroupCount,
            SUM(CASE WHEN bgs.status = 'C' THEN 1 ELSE 0 END) as SoftClosedGroupCount,
            SUM(CASE WHEN bgs.status = 'H' THEN 1 ELSE 0 END) as HardClosedGroupCount
FROM vw_all_billing_groups_status bgs
GROUP BY id_usage_interval
	