
-- ===========================================================
-- Create a VIEW [on t_acc_usage_interval, t_billgroup_member and t_billgroup] which specifies
-- the following for each interval:

-- the unassigned accounts i.e. the accounts for the interval which are not assigned
-- to any billing group
-- ===========================================================
CREATE VIEW vw_unassigned_accounts AS
SELECT pa.IntervalID, pa.AccountID, pa.State
FROM vw_paying_accounts pa  
WHERE  pa.AccountID NOT IN (SELECT id_acc 
			            FROM t_billgroup_member bgm 
			            INNER JOIN t_billgroup bg 
                                                ON bg.id_billgroup = bgm.id_billgroup AND
			                  bg.id_usage_interval = pa.IntervalID)
GROUP BY pa.IntervalID, pa.AccountID, pa.State
	