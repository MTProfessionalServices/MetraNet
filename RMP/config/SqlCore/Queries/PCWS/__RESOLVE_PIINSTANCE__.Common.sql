
		select id_prop from 
		t_pl_map plMap %%UPDLOCK%%
		join
		t_base_props bp  %%UPDLOCK%% on plMap.id_pi_instance = bp.id_prop
		where id_paramtable is null and id_po = %%ID_PO%% and %%PREDICATE%%
                