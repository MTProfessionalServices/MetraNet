set nocount on
go
INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('5.1.1', getdate(), 'R')
go
drop index t_acc_bucket_map.idx1_t_acc_bucket_map
go
CREATE NONCLUSTERED INDEX idx1_t_acc_bucket_map ON t_acc_bucket_map (id_usage_interval, bucket, status)
GO
UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
go
