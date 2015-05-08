DECLARE l_count PLS_INTEGER;
BEGIN
   SELECT COUNT ( * ) INTO l_count  FROM USER_TAB_COLUMNS  WHERE table_name = upper('t_failed_transaction') AND column_name = upper('dt_Start_Resubmit');
   IF l_count = 0
   THEN
      execute immediate 'alter table t_failed_transaction add dt_Start_Resubmit TIMESTAMP NULL';
   END IF;
END;

DECLARE l_count PLS_INTEGER;
BEGIN
   SELECT COUNT ( * ) INTO l_count  FROM USER_TAB_COLUMNS  WHERE table_name =  upper('t_failed_transaction') AND column_name =  upper('resubmit_Guid');
   IF l_count = 0
   THEN
      execute immediate 'alter table t_failed_transaction add resubmit_Guid VARCHAR2(36) NULL';
   END IF;
END;