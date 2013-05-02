
	select c.id_charge, bp.nm_name, bp.nm_display_name, c.id_pi, c.id_amt_prop from t_charge c inner join t_base_props bp on c.id_charge=bp.id_prop where c.id_charge = %%ID_CHARGE%%
  