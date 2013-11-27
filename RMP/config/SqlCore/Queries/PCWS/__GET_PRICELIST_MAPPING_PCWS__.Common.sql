
				select id_pricelist, id_pi_template from t_pl_map
				where
				id_po = %%PO_ID%%
				and
				id_pi_instance = %%PI_ID%%
				and
				id_paramtable = %%PT_ID%%
				AND
				id_sub is null and id_acc is null
			