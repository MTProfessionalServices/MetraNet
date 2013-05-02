
          select 
	          rc.id_prop ID,
	          bp.nm_name Name
          from 
          t_aj_template_reason_code_map map
          inner join t_reason_code rc on map.id_reason_code = rc.id_prop
          inner join t_base_props bp on rc.id_prop = bp.id_prop
          where id_adjustment = %%ADJ_ID%%
        