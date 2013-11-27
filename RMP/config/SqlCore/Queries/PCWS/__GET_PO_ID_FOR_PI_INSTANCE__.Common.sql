
				select 
					id_po 
				from 
					t_pl_map map
					inner join
					t_base_props bp on map.id_pi_instance = bp.id_prop
				where 
					%%PREDICATE%% and id_paramtable is null
			