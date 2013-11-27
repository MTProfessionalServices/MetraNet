use %%NETMETER%%

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_pending_payment_trans]') AND type in (N'U'))
DROP TABLE [dbo].[t_pending_payment_trans]
GO

CREATE TABLE t_pending_payment_trans 
(
	[id_interval] [int] NOT NULL,
	[id_acc] [int] NOT NULL,
	[id_payment_instrument] [nvarchar](72) NOT NULL,
	[nm_invoice_num] [nvarchar](50) NOT NULL,
	[dt_invoice] [datetime] NOT NULL,
	[nm_po_number] [nvarchar](30) NULL,
	[nm_description] [nvarchar](100) NULL,
	[nm_currency] [nvarchar](10) NOT NULL,
	[n_amount] [decimal](18, 6) NOT NULL,
	[id_authorization] [nvarchar](72) NULL,
	[b_captured] [char](1) NOT NULL,

	CONSTRAINT [PK_t_pending_payment_trans] PRIMARY KEY CLUSTERED
	(
		[id_interval] ASC,
		[id_acc] ASC,
		[id_payment_instrument] ASC
	)
)