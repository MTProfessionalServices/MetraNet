
create or replace force VIEW vw_unassigned_accounts AS
SELECT pa.IntervalID, pa.AccountID, pa.State
FROM vw_paying_accounts pa  
WHERE  pa.AccountID NOT IN (SELECT id_acc 
			            FROM t_billgroup_member bgm 
			            INNER JOIN t_billgroup bg ON bg.id_billgroup = bgm.id_billgroup 
			            where bg.id_usage_interval = pa.IntervalID)
GROUP BY pa.IntervalID, pa.AccountID, pa.State
	