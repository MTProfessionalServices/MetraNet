
SELECT column_value as id_acc FROM table(dbo.CSVToInt('%%ACCOUNT_IDS%%')) WHERE column_value NOT IN (SELECT id_acc FROM t_acc_usage_interval WHERE id_usage_interval = %%ID_INTERVAL%%)
/* ===========================================================
Return those accounts in %%ACCOUNT_IDS%% which don't have a mapping in t_acc_usage_interval for the given %%ID_INTERVAL%%.
============================================================== */
       
 