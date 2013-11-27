
		  CREATE TABLE t_ps_preauth_details (
		  id_preauth_tx_id_detail int NOT NULL,
		  id_preauth_tx_id [nvarchar](72) NOT NULL,
		  nm_invoice_num nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  dt_invoice_date datetime NULL,
		  nm_po_number nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  n_amount numeric(22,10) NULL,
		  CONSTRAINT PK_t_ps_preauth_details PRIMARY KEY CLUSTERED
		  (
		  id_preauth_tx_id_detail, id_preauth_tx_id
		  ))
	  