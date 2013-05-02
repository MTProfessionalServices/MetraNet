
				select id_prop from 
				t_pricelist pl %%UPDLOCK%%
				join
				t_base_props bp %%UPDLOCK%% on pl.id_pricelist = bp.id_prop
				where %%PREDICATE%% and n_type = 1
		