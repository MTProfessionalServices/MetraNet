
			   CREATE TABLE t_language(id_lang_code int NOT NULL,
				 tx_lang_code varchar(10) NULL,
	       n_order int NULL,
	       tx_description nvarchar(255) NULL,
				 CONSTRAINT PK_t_language PRIMARY KEY CLUSTERED (id_lang_code))
			 