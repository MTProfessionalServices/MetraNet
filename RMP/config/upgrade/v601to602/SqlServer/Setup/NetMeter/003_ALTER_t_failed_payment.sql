use %%NETMETER%%

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT

BEGIN TRANSACTION

IF NOT EXISTS (Select [name] from sys.columns where object_id = object_id(N'[dbo].[t_failed_payment]')
and [name] in ('n_retrycount', 'dt_lastretry') ) 
BEGIN
	ALTER TABLE dbo.t_failed_payment ADD
		[n_retrycount] [int] NULL,
		[dt_lastretry] [datetime] NULL
END

GO

COMMIT
