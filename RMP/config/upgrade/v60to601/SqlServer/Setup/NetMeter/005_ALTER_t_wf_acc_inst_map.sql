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
IF EXISTS (Select [name] from sys.columns where object_id = object_id(N'[dbo].[t_wf_acc_inst_map]')
and [name] in ('workflow_type') ) 
BEGIN
	ALTER TABLE dbo.t_wf_acc_inst_map 
		ALTER COLUMN workflow_type nvarchar(250) NOT NULL
END
commit