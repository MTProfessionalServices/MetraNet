
/* ===========================================================
1) Delete data from t_billgroup_tmp
2) Delete data from t_billgroup_member_tmp
3) Delete data from t_billgroup_source_acc
4) Delete data from t_billgroup_constraint_tmp
5) Update t_billgroup_materialization
=========================================================== */
CREATE PROCEDURE CleanupMaterialization
(
  @id_materialization INT,
  @dt_end DATETIME,
  @tx_status VARCHAR(10),
  @tx_failure_reason VARCHAR(4096),
  @status INT OUTPUT
)
AS

BEGIN
   -- initialize @status to failure (-1)
   SET @status = -1 

   BEGIN TRAN

  -- delete data from t_billgroup_tmp
  IF @id_materialization IS NOT NULL
     BEGIN
       /* ESR-2814 & ESR-3553 LOCK t_billgroup TO PREVENT two "CleanUpMaterialization" procedures from being run at the same time */
        
        delete from t_billgroup_tmp WITH (TABLOCKX) where id_materialization = @id_materialization

        /* ESR-2814 & ESR-3553 use truncate instead of delete, deleting millions of rows can cause the UI to timeout*/     
        exec ('truncate table t_billgroup_member_tmp')
        exec ('truncate table t_billgroup_source_acc') 
        DELETE t_billgroup_constraint_tmp WHERE id_usage_interval = (SELECT id_usage_interval 
                                                                     FROM t_billgroup_materialization
                                                                     WHERE id_materialization = @id_materialization) 

         UPDATE t_billgroup_materialization 
         SET dt_end = @dt_end, 
                tx_status = @tx_status,
                tx_failure_reason = @tx_failure_reason
         WHERE id_materialization = @id_materialization

     END
  ELSE
     BEGIN
 /*  ESR-2814 & ESR-3553  LOCK t_billgroup TO PREVENT two "CleanUpMaterialization" procedures from being run at the same time */ 
         delete from t_billgroup_tmp WITH (TABLOCKX) 
         
     /* ESR-2814 & ESR-3553 use truncate instead of delete, deleting millions of rows can cause the UI to timeout*/     
       exec ('truncate table t_billgroup_member_tmp')
       exec ('truncate table t_billgroup_source_acc')
       exec ('truncate table t_billgroup_constraint_tmp')  
     END

   -- set @status to success
   SET @status = 0 

   COMMIT TRAN

END
