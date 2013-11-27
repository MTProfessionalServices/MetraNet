use %%METRAPAY%%

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_ps_audit]') AND type in (N'U'))
DROP TABLE [dbo].[t_ps_audit]
GO

CREATE TABLE t_ps_audit (
	id_audit [nvarchar](72) NOT NULL,
	id_request_type int NOT NULL,
	id_transaction nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	dt_transaction datetime NOT NULL,
	n_payment_method_type int NOT NULL,
	nm_truncd_acct_num nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	n_creditcard_type int NULL,
	n_account_type int NULL,
	nm_invoice_num nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	dt_invoice_date datetime NULL,
	nm_po_number nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	nm_description nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	n_currency nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	n_amount numeric(18, 6) NOT NULL,
	CONSTRAINT PK_t_ps_audit PRIMARY KEY CLUSTERED
	(
		id_audit
	)
)