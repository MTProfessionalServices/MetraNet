
           CREATE TABLE t_namespace (
        nm_space nvarchar2(40) NOT NULL ,
        tx_desc nvarchar2 (255) NOT NULL ,
        nm_method nvarchar2 (255) NULL ,
        tx_typ_space nvarchar2 (40) NOT NULL,
                CONSTRAINT PK_T_NAMESPACE PRIMARY KEY (nm_space))

       