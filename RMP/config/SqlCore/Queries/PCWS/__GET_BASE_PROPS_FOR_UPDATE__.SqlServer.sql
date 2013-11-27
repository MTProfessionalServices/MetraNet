
			  select nm_name, nm_desc, nm_display_name from t_base_props with(updlock) where id_prop = %%ID_PROP%%
		  