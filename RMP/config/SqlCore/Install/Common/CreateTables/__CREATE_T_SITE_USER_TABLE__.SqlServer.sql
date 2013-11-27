
			     CREATE TABLE t_site_user (nm_login nvarchar(255) NOT NULL,
				 id_site int NOT NULL, id_profile int NULL, CONSTRAINT
				 PK_t_site_user PRIMARY KEY CLUSTERED (nm_login, id_site)
				 )
			 