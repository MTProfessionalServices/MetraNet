
           CREATE TABLE t_description
            (id_desc number(10) NOT NULL,
             id_lang_code number(10) NOT NULL,
             tx_desc nvarchar2(2000) NULL,
             tx_URL_desc nvarchar2(255) NULL,
             CONSTRAINT PK_t_description PRIMARY KEY (id_desc, id_lang_code)
          )
       