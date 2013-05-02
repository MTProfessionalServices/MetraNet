
/* ===========================================================
Returns the id_acc for the given username and namespace
=========================================================== */
SELECT id_acc 
FROM t_account_mapper
WHERE nm_login = '%%USERNAME%%' AND
            nm_space = '%%NAMESPACE%%'
   