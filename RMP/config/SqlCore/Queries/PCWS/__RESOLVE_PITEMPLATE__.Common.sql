
		select id_prop from 
		t_pi_template pit %%UPDLOCK%%
		join
		t_base_props bp %%UPDLOCK%% on pit.id_template = bp.id_prop
		where %%PREDICATE%%
    