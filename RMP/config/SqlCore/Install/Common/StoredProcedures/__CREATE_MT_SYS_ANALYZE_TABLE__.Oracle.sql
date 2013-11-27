CREATE OR REPLACE PROCEDURE mt_sys_analyze_table (
   p_table_name       VARCHAR2,
   p_sampling_ratio   NUMBER   DEFAULT DBMS_STATS.auto_sample_size,
   p_username         VARCHAR2 DEFAULT USER
)
AUTHID CURRENT_USER
AS
  /* create stats for a specfic table within its own transaction and commit the stats */  
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_owner        all_tables.owner%TYPE;
   v_table_name   all_tables.table_name%TYPE;
BEGIN
   /* Update statistics for a specific table within its own transaction */
   /* and then commit the autonomous transaction. */
   v_owner := UPPER(NVL (p_username, USER));
   v_table_name := UPPER (p_table_name);
   DBMS_STATS.gather_table_stats (ownname               => v_owner,
                                  tabname               => v_table_name,
                                  estimate_percent      => p_sampling_ratio,
                                  cascade               => TRUE,
                                  no_invalidate         => FALSE
                                 );
   COMMIT;
END;        
	