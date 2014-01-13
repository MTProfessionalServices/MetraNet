
/* Recreate seq_t_sys_upgrade and ensure NEXTVAL will be correct. */
/* This mitigates problems from old upgrade scripts that did not  */
/* update this sequence.                                          */

DECLARE
   l_max_id t_sys_upgrade.upgrade_id%TYPE;
BEGIN
   select nvl(max(upgrade_id),1) into l_max_id from t_sys_upgrade;
   l_max_id := l_max_id + 1;  
   execute immediate 'drop   sequence seq_t_sys_upgrade';
   execute immediate 'create sequence seq_t_sys_upgrade increment by 1' ||
                     ' start with ' || TO_CHAR( l_max_id ) ||
                     ' nocache order nocycle';
END;
/

/* Leave above blank line */

INSERT INTO t_sys_upgrade
(upgrade_id,target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
(seq_t_sys_upgrade.nextval,'6.4.0', sysdate, 'R');

commit;

/**************************************************************/
/***** Perform Schema Upgrades                            *****/
/**************************************************************/




/**************************************************************/
/***** All Done                                           *****/
/**************************************************************/

UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = sysdate
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade);

commit;
