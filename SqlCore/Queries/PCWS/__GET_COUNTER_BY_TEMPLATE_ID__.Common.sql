
			select 
	            id_counter ID,
              bp3.nm_name Name,
              bp2.nm_name CounterTypeName,
              bp3.nm_desc Description,
              bp.nm_name CounterPropertyName
            from t_counter cnt
            inner join t_counter_map map on cnt.id_prop = map.id_counter
            inner join t_counterpropdef cpd on map.id_cpd = cpd.id_prop
            inner join t_base_props bp on cpd.id_prop = bp.id_prop
            inner join t_base_props bp2 on cnt.id_counter_type = bp2.id_prop
            inner join t_base_props bp3 on cnt.id_prop = bp3.id_prop
            where map.id_pi = %%TEMPLATE_ID%%
        