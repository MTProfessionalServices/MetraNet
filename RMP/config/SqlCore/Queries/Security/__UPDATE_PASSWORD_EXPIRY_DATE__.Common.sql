
         update t_user_credentials set dt_expire =  %%EXPIRYDATE%%
         where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%USERNAME%%') and %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
        