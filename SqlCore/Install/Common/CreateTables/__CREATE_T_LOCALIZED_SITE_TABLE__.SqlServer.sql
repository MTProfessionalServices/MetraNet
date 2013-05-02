
			     CREATE TABLE t_localized_site (id_site int identity (1000, 1) NOT NULL,
				 nm_space nvarchar(40) NOT NULL, tx_lang_code varchar(10) NOT NULL,
				 CONSTRAINT PK_t_localized_site PRIMARY KEY CLUSTERED (id_site))
			 