use %%NETMETER%%

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_failed_payment]') AND type in (N'U'))
DROP TABLE [dbo].[t_failed_payment]
GO

CREATE TABLE t_failed_payment 
(
	[id_interval] [int] NOT NULL,
	[id_acc] [int] NOT NULL,
	[id_payment_instrument] [nvarchar](72) NOT NULL,
	[dt_original_trans] [datetime] NOT NULL,
	[nm_invoice_num] [nvarchar](50) NOT NULL,
	[dt_invoice] [datetime] NOT NULL,
	[nm_po_number] [nvarchar](30) NULL,
	[nm_description] [nvarchar](100) NULL,
	[nm_currency] [nvarchar](10) NOT NULL,
	[n_amount] [decimal](18, 6) NOT NULL,

	CONSTRAINT [PK_t_failed_payment] PRIMARY KEY CLUSTERED
	(
		[id_interval] ASC,
		[id_acc] ASC,
		[id_payment_instrument] ASC
	)
)