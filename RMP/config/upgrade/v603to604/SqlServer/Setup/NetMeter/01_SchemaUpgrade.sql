use %%NETMETER%%

set nocount on
go
INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('6.0.4', getdate(), 'R')
go

PRINT N'Altering [dbo].[t_batch] table'
GO

ALTER TABLE dbo.t_batch ADD
	n_dismissed int NULL default 0
GO
ALTER TABLE [dbo].[t_batch]  WITH CHECK ADD  CONSTRAINT [UK_7_t_batch] CHECK  (([n_dismissed]>=(0)))
GO
ALTER TABLE [dbo].[t_batch] CHECK CONSTRAINT [UK_7_t_batch]
GO

UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
go

