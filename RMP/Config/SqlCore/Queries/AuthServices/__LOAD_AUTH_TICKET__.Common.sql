SELECT id_acc,
       nm_space,
       nm_login,
       n_lifespanminutes,
       dt_expiration,
	   id_lang_code
FROM   t_active_tickets %%UPDLOCK%%
WHERE  id_ticket = ? and nm_salt = ?