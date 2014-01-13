
/* ===========================================================
Return those accounts in %%ACCOUNT_IDS%% which don't have a mapping in t_acc_usage_interval for the given %%ID_INTERVAL%%.
============================================================== */
begin
DECLARE @args TABLE
( 
  id_acc INT NOT NULL
)
INSERT INTO @args SELECT value FROM CSVToInt('%%ACCOUNT_IDS%%')
SELECT id_acc FROM @args WHERE id_acc NOT IN (SELECT id_acc FROM t_acc_usage_interval WHERE id_usage_interval = %%ID_INTERVAL%%)
end
       
 