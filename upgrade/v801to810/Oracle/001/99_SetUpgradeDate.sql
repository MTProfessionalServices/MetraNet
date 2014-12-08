SET DEFINE OFF

UPDATE
    t_sys_upgrade
SET
    dt_end_db_upgrade = SYSDATE,
	db_upgrade_status = 'C'
where dt_end_db_upgrade is null and db_upgrade_status = 'R'
/
