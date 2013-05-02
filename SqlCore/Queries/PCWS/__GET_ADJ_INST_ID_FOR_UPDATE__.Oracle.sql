
			  select a.id_prop from
			  t_adjustment a
			  inner join
			  t_base_props bp on a.id_adjustment_type = bp.id_prop
			  where bp.nm_name = '%%ADJ_NAME%%' and a.id_pi_instance = %%PI_ID%%
		  