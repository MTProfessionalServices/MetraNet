
				select id_prop from 
				(select id_view id_prop, nm_name from t_prod_view %%UPDLOCK%%) pv
				where %%PREDICATE%%
		