SELECT DISTINCT TABLE_NAME
FROM   ALL_TABLES 
WHERE OWNER = USER AND (TABLE_NAME LIKE 'T_SVC_%'
OR TABLE_NAME LIKE 'T_PV_%'
OR TABLE_NAME in ('T_ACC_USAGE', 'T_MESSAGE', 'T_SESSION', 'T_SESSION_SET', 'T_SESSION_STATE'))