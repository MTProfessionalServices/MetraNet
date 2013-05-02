
update t_account
set dt_end = %%ACCOUNT_END_DATE%%,
    id_status = %%ACCOUNT_STATUS%%
where id_acc =
         ( select id_acc
          from t_account_mapper
          where %%%UPPER%%%(nm_login) = %%%UPPER%%%(n'%%LOGIN_ID%%')
             and %%%UPPER%%%(nm_space) = %%%UPPER%%%(n'%%NAME_SPACE%%') )
      