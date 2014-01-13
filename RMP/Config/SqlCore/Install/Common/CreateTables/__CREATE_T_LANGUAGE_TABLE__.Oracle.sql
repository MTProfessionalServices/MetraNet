
           CREATE TABLE t_language(id_lang_code number(10) NOT NULL,
         tx_lang_code varchar2(10) NULL,
	 n_order number(10) NULL,
         tx_description nvarchar2(255) NULL,
         CONSTRAINT PK_t_language PRIMARY KEY (id_lang_code))
       