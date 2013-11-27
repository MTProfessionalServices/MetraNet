
		            select id_prop from 
					t_sub subs
					inner join
		            t_pl_map plMap %%UPDLOCK%% on plMap.id_po = subs.id_po
		            join
		            t_base_props bp  %%UPDLOCK%% on plMap.id_pi_instance = bp.id_prop
		            where id_paramtable is null and subs.id_sub = %%ID_PO%% and %%PREDICATE%%
                