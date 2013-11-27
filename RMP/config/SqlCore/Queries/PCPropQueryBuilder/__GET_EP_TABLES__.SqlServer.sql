
				select 't_base_props' nm_ep_tablename
				UNION
				select nm_ep_tablename from t_ep_map where id_principal = %%KIND%%
			