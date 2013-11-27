use %%NETMETER%%

set nocount on
go
INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES	('6.6', getdate(), 'C')

go

PRINT 'Update t_composite_capability_type to use business MODELING entities'
UPDATE t_composite_capability_type SET tx_name='Read Business Modeling Entities' WHERE tx_name ='Read Business Entities'
UPDATE t_composite_capability_type SET tx_name='Write Business Modeling Entities' WHERE tx_name ='Write Business Entities'