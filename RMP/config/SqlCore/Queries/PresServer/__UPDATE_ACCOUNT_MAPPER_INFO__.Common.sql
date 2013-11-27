
update t_account_mapper
set nm_space = N'%%NEW_NAME_SPACE%%',
    nm_login = N'%%NEW_LOGIN_ID%%'
where %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
   and %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%')
   		