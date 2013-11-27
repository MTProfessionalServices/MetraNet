
        update t_acc_template_session 
          set n_retries = n_retries + 1 
          output inserted.n_retries as NumRetries
          where id_session = %%SESSION_ID%%
        