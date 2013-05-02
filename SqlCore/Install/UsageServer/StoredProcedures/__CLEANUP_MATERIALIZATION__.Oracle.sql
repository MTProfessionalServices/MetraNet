
/* ===========================================================
1) Delete data from t_billgroup_tmp
2) Delete data from t_billgroup_member_tmp
3) Delete data from t_billgroup_source_acc
4) Delete data from t_billgroup_constraint_tmp
5) Update t_billgroup_materialization
=========================================================== */
CREATE OR REPLACE
PROCEDURE CleanupMaterialization
(
  p_id_materialization INT,
  p_dt_end DATE,
  p_tx_status VARCHAR2,
  p_tx_failure_reason VARCHAR2,
  status out INT 
)
AS

BEGIN
   /* initialize @status to failure (-1) */
   status := -1;

  /* delete data from t_billgroup_tmp */
  IF p_id_materialization IS NOT NULL then

    /*  ESR-2814 LOCK t_billgroup TO PREVENT two "CleanUpMaterialization" procedures from being run at the same time */ 
    LOCK TABLE t_billgroup_tmp IN EXCLUSIVE MODE; 
    DELETE t_billgroup_tmp WHERE id_materialization = p_id_materialization;
    
    /* ESR-2814 use truncate instead of delete, deleting millions of rows can cause the UI to timeout*/     
    exec_ddl ('truncate table t_billgroup_member_tmp');
    exec_ddl ('truncate table t_billgroup_source_acc'); 
    DELETE t_billgroup_constraint_tmp 
      WHERE id_usage_interval = (
        SELECT id_usage_interval 
          FROM t_billgroup_materialization
          WHERE id_materialization = p_id_materialization); 
    
     UPDATE t_billgroup_materialization 
     SET dt_end = p_dt_end, 
        tx_status = p_tx_status,
        tx_failure_reason = p_tx_failure_reason
     WHERE id_materialization = p_id_materialization;
  ELSE
    /*  ESR-2814 LOCK t_billgroup TO PREVENT two "CleanUpMaterialization" procedures from being run at the same time */ 
    LOCK TABLE t_billgroup_tmp IN EXCLUSIVE MODE; 
    DELETE t_billgroup_tmp;
    /* ESR-2814 use truncate instead of delete, deleting millions of rows can cause the UI to timeout*/     
    exec_ddl ('truncate table t_billgroup_member_tmp');
    exec_ddl ('truncate table t_billgroup_source_acc'); 
    exec_ddl ('truncate table t_billgroup_constraint_tmp'); 
  END if;

   /* set @status to success */
   status := 0;

   commit;
end  CleanupMaterialization;
