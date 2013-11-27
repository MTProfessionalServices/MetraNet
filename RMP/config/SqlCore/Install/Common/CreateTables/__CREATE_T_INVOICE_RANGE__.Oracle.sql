
       CREATE TABLE t_invoice_range
          (id_interval number(10) NOT NULL,
					id_billgroup number(10) NOT NULL,
           namespace nvarchar2(40) NOT NULL,
           id_invoice_num_first number(10) NOT NULL,
           id_invoice_num_last number(10) NOT NULL,
           id_run number(10) NULL)
      