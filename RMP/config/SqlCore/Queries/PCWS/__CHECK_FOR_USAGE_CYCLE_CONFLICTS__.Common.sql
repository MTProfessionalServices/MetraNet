
			  select bp.nm_name from
				(
				select 
					r.id_prop,
					r.tx_cycle_mode,
					r.id_cycle_type 
				from
					t_pl_map plMap
					inner join 
					t_recur r on plMap.id_pi_instance = r.id_prop
				where
					(tx_cycle_mode = 'EBCR' or tx_cycle_mode = 'BCR Constrained')
					and
					id_po = %%ID_PO%%
				union
				select 
					id_prop, 
					'BCR Constrained' tx_cycle_mode, 
					id_cycle_type
				from
					t_pl_map plMap
					inner join 
					t_aggregate a on plMap.id_pi_instance = a.id_prop
				where
					id_po = %%ID_PO%%
					and
					id_cycle_type is not null
				union
				select 
					id_prop,
					'BCR Constrained' tx_cycle_mode,
					id_cycle_type 
				from
					t_pl_map plMap
					inner join 
					t_discount d on plMap.id_pi_instance = d.id_prop
				where
					id_po= %%ID_PO%%
					and
					id_cycle_type is not null
				) existingCycles
				inner join
				t_base_props bp on existingCycles.id_prop = bp.id_prop
				where
					(tx_cycle_mode = '%%CYCLE_MODE%%' and id_cycle_type != %%CYCLE_TYPE%%)
					or
					(
						((4=%%CYCLE_TYPE%% or 5=%%CYCLE_TYPE%%) and (id_cycle_type != 4 and id_cycle_type != 5))
						or
						((1=%%CYCLE_TYPE%% or 7=%%CYCLE_TYPE%% or 8=%%CYCLE_TYPE%%) and (id_cycle_type != 1 and id_cycle_type != 7 and id_cycle_type != 8))
					)
			  