
          update t_acc_template_session 
                set 
                      id_recovered_by=%%RECOVERED_BY_ID%% 
                     ,n_status = %%SESSION_STATUS%%
                where id_session = %%SESSION_ID%%
        