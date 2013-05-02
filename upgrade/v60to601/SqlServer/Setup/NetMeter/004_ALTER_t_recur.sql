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

IF NOT EXISTS (Select [name] from sys.columns where object_id = object_id(N'[dbo].[t_recur]')
and [name] in ('n_unit_name', 'n_unit_display_name', 'nm_unit_display_name') ) 
BEGIN
	ALTER TABLE dbo.t_recur ADD
		n_unit_name int NULL,
		n_unit_display_name int NULL,
		nm_unit_display_name nvarchar(255) NULL

END

COMMIT
