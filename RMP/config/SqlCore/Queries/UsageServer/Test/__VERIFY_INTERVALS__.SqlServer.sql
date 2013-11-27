
/* ===========================================================
Return those intervals in %%INTERVAL_IDS%% which don't exist in t_usage_interval.
============================================================== */
BEGIN
DECLARE @args TABLE
( 
  id_interval INT NOT NULL
)
INSERT INTO @args SELECT value FROM CSVToInt('%%INTERVAL_IDS%%')
SELECT id_interval FROM @args WHERE id_interval NOT IN (SELECT id_interval FROM t_usage_interval)
END
       
 