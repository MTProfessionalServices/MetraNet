
        BEGIN
        update t_acc_template_session 
          set n_retries = n_retries + 1 
          where id_session = %%SESSION_ID%%;
       open :1 for
       select n_retries NumRetries from t_acc_template_session where id_session = %%SESSION_ID%%;
       end;
        