
      CREATE TABLE t_product_view_log (nm_product_view nvarchar2(100) NOT NULL,
      id_revision number(10) NOT NULL, tx_checksum varchar2(100) NOT NULL,
      CONSTRAINT PK_t_product_view_log PRIMARY KEY (nm_product_view))
      