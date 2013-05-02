
				delete from t_site_user where upper(nm_login) = upper(N'%%LOGIN_ID%%')
				and id_site = %%SITE_ID%%
			