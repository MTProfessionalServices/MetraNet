use %%METRAPAY%%

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_ps_preauth]') AND type in (N'U'))
DROP TABLE [dbo].[t_ps_preauth]
GO

CREATE TABLE t_ps_preauth 
(
	id_preauth_tx_id [nvarchar](72) NOT NULL,
	id_pymt_instrument nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	dt_transaction datetime NOT NULL,
	nm_invoice_num nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	dt_invoice_date datetime NULL,
	nm_po_number nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	nm_description nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	n_currency nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	n_amount numeric(18, 6) NOT NULL,
	n_request_params nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	
	CONSTRAINT PK_t_ps_preauth PRIMARY KEY CLUSTERED
	(
		id_preauth_tx_id
	)
)