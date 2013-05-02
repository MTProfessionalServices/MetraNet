select seq_t_sys_upgrade.nextval from dual;

INSERT INTO t_sys_upgrade
(upgrade_id,target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
(seq_t_sys_upgrade.nextval,'5.1.1', sysdate, 'R');

DROP INDEX IDX_T_ACC_BUCKET_MAP;

CREATE UNIQUE INDEX IDX_T_ACC_BUCKET_MAP ON T_ACC_BUCKET_MAP
(ID_ACC, ID_USAGE_INTERVAL, TT_END);

DROP INDEX IDX1_T_ACC_BUCKET_MAP;

CREATE INDEX IDX1_T_ACC_BUCKET_MAP ON T_ACC_BUCKET_MAP
(BUCKET, STATUS);

UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = sysdate
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)    ;

