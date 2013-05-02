
				select cpd.id_prop id_prop from 
				t_counterpropdef cpd %%UPDLOCK%%
				join
				t_base_props bp %%UPDLOCK%% on cpd.id_prop = bp.id_prop
				where %%PREDICATE%%
		