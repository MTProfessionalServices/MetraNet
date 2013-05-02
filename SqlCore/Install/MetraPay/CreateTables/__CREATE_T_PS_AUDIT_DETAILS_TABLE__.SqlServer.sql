
		  CREATE TABLE t_ps_audit_details (
		  id_audit_detail int NOT NULL,
		  id_audit [nvarchar](72) NOT NULL,
		  nm_invoice_num nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  dt_invoice_date datetime NULL,
		  nm_po_number nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		  n_amount numeric(22,10) NULL,
		  CONSTRAINT PK_t_ps_audit_details PRIMARY KEY CLUSTERED
		  (
		  id_audit_detail, id_audit
		  ))
	  