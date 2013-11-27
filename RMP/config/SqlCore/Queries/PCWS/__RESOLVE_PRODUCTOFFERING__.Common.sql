
		select id_prop from 
		t_po po %%UPDLOCK%%
		join
		t_base_props bp %%UPDLOCK%% on po.id_po = bp.id_prop
		where %%PREDICATE%%
    