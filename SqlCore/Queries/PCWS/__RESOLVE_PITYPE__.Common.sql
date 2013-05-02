
		select id_prop from 
		t_pi pi %%UPDLOCK%%
		join
		t_base_props bp %%UPDLOCK%% on pi.id_pi = bp.id_prop
		where %%PREDICATE%%
    