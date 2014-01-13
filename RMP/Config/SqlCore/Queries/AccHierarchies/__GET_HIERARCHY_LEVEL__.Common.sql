         
          select num_generations from t_account_ancestor
          where id_descendent=%%ANCESTOR%%
          and id_ancestor=1
          and %%REFDATE%% between vt_start and vt_end
        