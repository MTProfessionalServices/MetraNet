
				select rc.id_prop from 
				t_reason_code rc %%UPDLOCK%%
				join
				t_base_props bp %%UPDLOCK%% on rc.id_prop = bp.id_prop
				where %%PREDICATE%%
		