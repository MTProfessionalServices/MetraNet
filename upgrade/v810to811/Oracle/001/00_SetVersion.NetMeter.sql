INSERT INTO t_sys_upgrade
(UPGRADE_ID, target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
((SELECT MAX(upgrade_id)+1 FROM t_sys_upgrade), '8.1.1', sysdate, 'R')