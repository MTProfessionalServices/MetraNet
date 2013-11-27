
/* ===========================================================
Return those accounts in %%ACCOUNT_IDS%% which don't exist in t_account_mapper.
============================================================== */
BEGIN
DECLARE @args TABLE
( 
  id_acc INT NOT NULL
)
INSERT INTO @args SELECT value FROM CSVToInt('%%ACCOUNT_IDS%%')
SELECT id_acc FROM @args WHERE id_acc NOT IN (SELECT id_acc FROM t_account_mapper)
END
 