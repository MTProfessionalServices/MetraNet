INSERT INTO t_sys_upgrade
  (target_db_version, dt_start_db_upgrade, dt_end_db_upgrade, db_upgrade_status)
  VALUES	('8.0.0', getdate(), getdate(), 'C')