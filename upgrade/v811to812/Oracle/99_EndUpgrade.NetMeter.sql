WHENEVER SQLERROR EXIT SQL.SQLCODE 

UPDATE t_sys_upgrade 
  SET dt_end_db_upgrade = SYSDATE,	db_upgrade_status = 'C'
  WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade) and db_upgrade_status = 'R'
  
/
