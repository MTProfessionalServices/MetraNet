
				/* performace gain functional indexes */
				create unique index fidx2_t_account_mapper on t_account_mapper(upper(nm_login),upper(nm_space));
				create unique index fidx1_t_site_user on t_site_user(upper(nm_login),id_site);
				create unique index fidx1_t_user_credentials on t_user_credentials(upper(nm_login),upper(nm_space)); 
				create index fidx1_t_account_mapper on t_account_mapper(upper(nm_space));

