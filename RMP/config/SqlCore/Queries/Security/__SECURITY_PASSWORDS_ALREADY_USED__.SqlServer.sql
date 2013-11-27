
          select top %%ROW_COUNT%% * from t_user_credentials_history 
          where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%USERNAME%%') and %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
          order by tt_end desc
        