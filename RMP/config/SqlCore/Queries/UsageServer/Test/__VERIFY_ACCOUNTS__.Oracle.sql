
SELECT column_value as id_acc FROM table(dbo.CSVToInt('%%ACCOUNT_IDS%%')) WHERE column_value NOT IN (SELECT id_acc FROM t_account_mapper)
/* ===========================================================
Return those accounts in %%ACCOUNT_IDS%% which don't exist in t_account_mapper.
============================================================== */
 