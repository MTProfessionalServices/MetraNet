SELECT id_acc,
       nm_space,
       nm_login,
       n_lifespanminutes,
       dt_expiration
FROM   t_active_tickets %%UPDLOCK%%
WHERE  id_ticket = ? and nm_salt = ?