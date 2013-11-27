
			CREATE TABLE t_product_view_log
			(nm_product_view nvarchar(100) NOT NULL,
			id_revision int NOT NULL,
			tx_checksum varchar(100) NOT NULL,
			CONSTRAINT PK_t_product_view_log PRIMARY KEY CLUSTERED (nm_product_view))
			