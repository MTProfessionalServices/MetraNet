
/* ===========================================================
Return the account name for the given id.
============================================================== */
SELECT nm_login 
FROM t_account_mapper 
WHERE id_acc = '%%ID_ACC%%' AND
      %%%UPPER%%%(nm_space) = %%%UPPER%%%('%%NAMESPACE%%')
 