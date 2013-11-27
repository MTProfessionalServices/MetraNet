
          select min(vt_start) vt_start,id_ancestor 
          from t_account_ancestor where id_descendent = %%ID_ACC%% AND 
          num_generations =1 
          group by id_ancestor
					