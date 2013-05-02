
           CREATE TABLE t_profile (id_profile number(10) NOT NULL,
         nm_tag nvarchar2(32) NOT NULL,
         val_tag nvarchar2(80) NULL, tx_desc nvarchar2(255) NULL,
         CONSTRAINT PK_t_profile PRIMARY KEY (id_profile,
         nm_tag))
       