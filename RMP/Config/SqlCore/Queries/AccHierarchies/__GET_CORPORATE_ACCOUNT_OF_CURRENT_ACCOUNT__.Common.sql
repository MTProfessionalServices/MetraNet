
			select id_ancestor, num_generations from t_account_ancestor where id_descendent=%%ID_ACC%% and vt_start <= %%EFF_DATE%%
			and vt_end > %%EFF_DATE%% and id_ancestor <> 1 and num_generations = (
			select max(num_generations) from t_account_ancestor where id_descendent=%%ID_ACC%% and vt_start <= %%EFF_DATE%%
			and vt_end > %%EFF_DATE%% and id_ancestor <> 1)
			