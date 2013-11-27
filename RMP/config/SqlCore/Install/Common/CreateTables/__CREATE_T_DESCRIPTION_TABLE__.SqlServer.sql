
			   CREATE TABLE t_description (id_desc int NOT NULL,
				 id_lang_code int NOT NULL, tx_desc nvarchar(4000) NULL,
         tx_URL_desc nvarchar(255) NULL,
				 CONSTRAINT PK_t_description PRIMARY KEY CLUSTERED (id_desc, id_lang_code)
				 )
			 