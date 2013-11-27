
	select count(*) from t_pl_map plm
		%%JOIN_CLAUSE%%
		where plm.id_po = %%ID_PO%% and id_pricelist is not NULL
		%%WHERE_COMPLEMENT%%
  