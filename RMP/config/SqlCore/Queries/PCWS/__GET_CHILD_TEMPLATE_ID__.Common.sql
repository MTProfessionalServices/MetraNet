
          select 
	          id_template ID,
	          bp.nm_name Name 
          from t_pi_template pit
          inner join t_base_props bp on pit.id_template = bp.id_prop
          where id_template_parent = %%PARENT_TEMPLATE_ID%%
        