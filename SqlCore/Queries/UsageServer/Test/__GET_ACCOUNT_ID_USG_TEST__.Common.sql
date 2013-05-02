
/* ===========================================================
Return the account id for the given user name.
============================================================== */
SELECT id_acc 
FROM t_account_mapper 
WHERE lower(nm_login) = lower('%%USER_NAME%%') AND
      lower(nm_space) = lower('%%NAMESPACE%%')
 