
/* ===========================================================
Inserts a row in t_billgroup_materialization 
Returns the materialization id

Returns:
-1 if an unknown error has occurred
-2 could not clean temporary data
-3 if this interval is hard closed
-4 if this interval does not have any paying accounts
-5 if atleast one interval-only adapter has executed successfully for the given interval
     and it's a rematerialization or a user defined billing group creation
-6 if an 'EOP' adapter associated with the given interval is 'Running' or 'Reversing'
-7 if a full materialization has already happened for the given interval
-8 if a materialization is in progress for the given interval
=========================================================== */
CREATE PROCEDURE CreateBillGroupMaterialization
(
  @id_user_acc INT,
  @dt_start DATETIME,
  @id_parent_billgroup INT,
  @id_usage_interval INT,
  @tx_type VARCHAR(20),
  @id_materialization INT OUTPUT,
  @status INT OUTPUT
)
AS

BEGIN
   BEGIN TRAN
   -- initialize @status to unknown error
   SET @status = -1 
   SET @id_materialization = 0
   
   /* Clean out temporary data */
   EXEC CleanupMaterialization NULL,  NULL, NULL, NULL, @status OUTPUT
   IF (@status != 0) 
       BEGIN
          SET @status = -2
          ROLLBACK
          RETURN 
       END
                  
   /* Reset status */   
   SET @status = -1 
                               
   /* Return error if this interval is hard closed */
   IF EXISTS(SELECT id_interval
                  FROM t_usage_interval
                  WHERE id_interval = @id_usage_interval AND
                              tx_interval_status = 'H')
      BEGIN
           SET @status = -3
           ROLLBACK
           RETURN 
      END

    /* Return error if this interval does not have any paying accounts */
   IF NOT EXISTS(SELECT 1
                          FROM vw_paying_accounts 
                          WHERE IntervalID = @id_usage_interval)
      BEGIN
           SET @status = -4
           ROLLBACK
           RETURN 
      END

   /* Error if atleast one interval-only adapter has executed successfully for the given interval 
       for a rematerialization */
   IF ((@tx_type = 'Rematerialization' OR @tx_type = 'UserDefined') AND
        EXISTS (SELECT id_instance
                    FROM t_recevent_inst ri
                    INNER JOIN t_recevent re
                         ON re.id_event = ri.id_event
                    WHERE ri.id_arg_interval = @id_usage_interval AND
                                re.tx_billgroup_support = 'Interval' AND
                                re.tx_type = 'EndOfPeriod' AND
                                ri.tx_status = 'Succeeded'))
    BEGIN
       SET @status = -5
       ROLLBACK
       RETURN 
     END

   /* Return error if there are any EOP adapter instances running or reversing in this interval */
   IF EXISTS(SELECT id_instance 
                  FROM t_recevent_inst ri
                  INNER JOIN t_recevent re 
                      ON re.id_event = ri.id_event
                  WHERE ri.id_arg_interval = @id_usage_interval AND
                              re.tx_type = 'EndOfPeriod' AND
                              ri.tx_status IN ('Running', 'Reversing'))
       BEGIN
           SET @status = -6
           ROLLBACK
           RETURN 
       END

   /* Return error if this is a pull list and the parent billing group is not soft closed 
   IF (@tx_type = 'PullList' AND 
       EXISTS (SELECT status 
                   FROM vw_all_billing_groups_status 
                   WHERE id_billgroup = @id_parent_billgroup AND
                               status != 'C'))
       BEGIN
           SET @status = -7
           ROLLBACK
           RETURN 
       END */
   
   IF NOT EXISTS (SELECT id_materialization 
	               FROM t_billgroup_materialization bm
	               WHERE bm.tx_status = 'InProgress' AND
	               bm.id_usage_interval = @id_usage_interval) 
   
       BEGIN
              /* Cannot have more than one 'Full' materialization for a given interval */
              IF (@tx_type = 'Full' AND EXISTS (SELECT id_materialization 
	                                                      FROM t_billgroup_materialization bm
	                                                      WHERE bm.tx_status = 'Succeeded' AND
                                                                              bm.tx_type = 'Full' AND
	                                                                  bm.id_usage_interval = @id_usage_interval))
                 BEGIN
                      SET @status = -7
                      ROLLBACK
                      RETURN 
                 END
              ELSE
                 BEGIN
                    -- insert a new row into t_billgroup_materialization
                    INSERT INTO t_billgroup_materialization 
                         (id_user_acc, dt_start, id_parent_billgroup, id_usage_interval, tx_status, tx_type)
                    VALUES  (@id_user_acc, @dt_start, @id_parent_billgroup, @id_usage_interval, 'InProgress', @tx_type)
           
                    -- assign the new identity created
                    SET @id_materialization = @@IDENTITY
                    SET @status = 0
                    COMMIT
                 END
        END
    ELSE 
        BEGIN
           SET @status = -8
           ROLLBACK
           RETURN 
        END
END
