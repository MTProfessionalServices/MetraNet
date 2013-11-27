
        SELECT	nm_name
		FROM 	t_base_props %%UPDLOCK%%
		WHERE	n_kind = %%N_KIND%%
		AND		nm_name = '%%NM_NAME%%'
		
      