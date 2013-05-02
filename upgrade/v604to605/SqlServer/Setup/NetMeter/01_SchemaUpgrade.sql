use %%NETMETER%%

set nocount on
go
INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('6.0.5', getdate(), 'R')
go

PRINT N'Inserting chinese in  [dbo].[t_language] table'
GO

insert into t_language (id_lang_code, tx_lang_code, n_order, tx_description) values (156, 'cn', NULL, 'Chinese')
GO


UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
go

