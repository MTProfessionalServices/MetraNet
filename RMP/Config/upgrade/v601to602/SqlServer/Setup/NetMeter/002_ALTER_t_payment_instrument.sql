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
IF NOT EXISTS (select * from sysindexes where [Name] = 'idx_t_payment_instrument_id_acct') 
BEGIN
	Create NONCLUSTERED INDEX idx_t_payment_instrument_id_acct on t_payment_instrument(id_acct)
END
GO

commit