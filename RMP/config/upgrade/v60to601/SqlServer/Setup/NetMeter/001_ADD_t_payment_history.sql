use %%NETMETER%%

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_payment_history]') AND type in (N'U'))
DROP TABLE [dbo].[t_payment_history]
GO

CREATE TABLE t_payment_history (
	id_payment_transaction nvarchar(72)NOT NULL,
	id_acct int NOT NULL,
	dt_transaction datetime NOT NULL,
	n_payment_method_type int NOT NULL,
	nm_truncd_acct_num nvarchar(20) NOT NULL,
	id_creditcard_type int NULL,
	n_account_type int NULL,
	nm_invoice_num nvarchar(50) NULL,
	dt_invoice_date datetime NOT NULL,
	nm_po_number nvarchar(30) NULL,
	nm_description nvarchar(100) NOT NULL,
	n_currency nvarchar(10) NOT NULL,
	n_amount numeric(18, 6) NOT NULL
	CONSTRAINT PK_t_payment_history PRIMARY KEY CLUSTERED 
	(
	  id_payment_transaction
	)
)