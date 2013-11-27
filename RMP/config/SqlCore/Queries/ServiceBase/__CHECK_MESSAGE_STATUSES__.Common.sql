
              select 
                dt_completed Completed
              from t_message %%LOCK%%
              where id_message in (%%ID_MESSAGES%%)
        