
				select cm.id_prop from 
				t_counter_metadata cm %%UPDLOCK%%
				join
				t_base_props bp %%UPDLOCK%% on cm.id_prop = bp.id_prop
				where %%PREDICATE%%
		