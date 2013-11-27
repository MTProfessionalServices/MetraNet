
				select id_ancestor from
				t_account_ancestor where id_descendent = %%DESCENDENT%% AND
        %%REF_DATE%% between vt_start AND vt_end AND
				num_generations = 1
				