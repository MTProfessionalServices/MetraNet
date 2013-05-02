
           CREATE TABLE t_localized_site (id_site number(10) NOT NULL,
         nm_space nvarchar2(40) NOT NULL, tx_lang_code varchar2(10) NOT NULL,
         CONSTRAINT PK_t_localized_site PRIMARY KEY (id_site))
       