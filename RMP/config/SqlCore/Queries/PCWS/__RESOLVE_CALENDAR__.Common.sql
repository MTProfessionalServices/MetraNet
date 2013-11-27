
		select id_prop from 
		t_calendar cal %%UPDLOCK%%
		join
		t_base_props bp %%UPDLOCK%% on cal.id_calendar = bp.id_prop
		where %%PREDICATE%%
                