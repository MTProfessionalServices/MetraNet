
/* ===========================================================
1) Clone t_recevent_inst data for the new billing group
2) Clone t_recevent_run data for the new billing group
3) Clone t_recevent_run_details data for the new billing group 
4) Clone t_recevent_run_batch data for the new billing group

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : The given id_materialization has a NULL id_parent_billgroup
   -3 : The given id_materialization is not a 'PullList' 
   -4 : The given id_materialization is not 'InProgress' 
   -5 : No billing group id found in t_billgroup_tmp for the given id_materialization
   -6 : No instances need to be copied
=========================================================== */
CREATE PROCEDURE CopyAdapterInstances
(
   @id_materialization INT,
   @status INT OUTPUT,
   @id_billgroup_parent INT OUTPUT,
   @id_billgroup_child INT OUTPUT
)
AS
   -- BEGIN TRAN

   DECLARE @tx_materialization_status VARCHAR(10)
   DECLARE @tx_materialization_type VARCHAR(10)
   DECLARE @id_usage_interval INT

   /* Initialize output variables */
   SET @status = -1
   SET @id_billgroup_parent = -1
   SET @id_billgroup_child = -1
    
   SELECT @id_billgroup_parent = id_parent_billgroup, 
               @tx_materialization_status = tx_status, 
               @tx_materialization_type = tx_type,
               @id_usage_interval = id_usage_interval
   FROM t_billgroup_materialization 
   WHERE id_materialization = @id_materialization
   
   /* Error if id_parent_billgroup is NULL */
   IF @id_billgroup_parent IS NULL
       BEGIN
         SET @status = -2
         -- ROLLBACK
         RETURN 
      END

   /* Error if tx_type is not a PullList */
   IF @tx_materialization_type != 'PullList'
       BEGIN
         SET @status = -3
         -- ROLLBACK
         RETURN 
      END

    /* Error if tx_status is not InProgress */
    IF @tx_materialization_status != 'InProgress'
       BEGIN
         SET @status = -4
         -- ROLLBACK
         RETURN 
      END
   
   -- Get the id_billgroup for the pull list being created
   SELECT @id_billgroup_child = id_billgroup
   FROM t_billgroup_tmp 
   WHERE id_materialization = @id_materialization

   IF @id_billgroup_child IS NULL
       BEGIN
         SET @status = -5
         -- ROLLBACK
         RETURN 
      END

   
   /*
       We need to clone those adapter instances from the
       parent billing group which have an adapter granularity of 'Account'
       t_recevent.tx_billgroup_support = 'Account'
   */
   
   /* Get the existing t_recevent_inst which will be copied */
   DECLARE @newInstances TABLE (id_instance_temp INT IDENTITY(1000,1) NOT NULL,
                                                       id_instance_parent INT,
                                                       id_instance_child INT,
                                                       id_event INT,
                                                       tx_status VARCHAR(14),
                                                       id_run_parent INT, 
                                                       id_run_child INT)

   INSERT @newInstances
   SELECT id_instance,
               NULL,
               ri.id_event,
               tx_status,
               NULL,
               NULL
   FROM t_recevent_inst ri
   INNER JOIN t_recevent re 
      ON re.id_event = ri.id_event
   WHERE ri.id_arg_billgroup = @id_billgroup_parent AND
               ri.id_arg_interval =  @id_usage_interval AND
               re.tx_billgroup_support IN ('Account')

   /* Return if there's nothing to be copied */
   DECLARE @newInstancesCount INT
   SELECT @newInstancesCount = COUNT(id_instance_temp) 
   FROM @newInstances

   IF (@newInstancesCount = 0)
       BEGIN
         SET @status = 0
         -- ROLLBACK
         RETURN 
      END

   /* Iterate over the items in @newInstances, creating copies */
   DECLARE @id_instance_temp INT
   DECLARE @id_instance_parent INT
   DECLARE @id_instance_child INT
   DECLARE @id_run_temp INT
   DECLARE @id_run_parent INT
   DECLARE @id_run_child INT
   DECLARE @id_run_parent_out INT
   DECLARE @id_run_child_out INT
   DECLARE @newRunsCount INT
   DECLARE @tx_instance_status VARCHAR(14)
   DECLARE @min_id_run_temp INT

   SET @id_instance_temp = 1000
   
   WHILE (@id_instance_temp < (1000 + @newInstancesCount))
       BEGIN
           -- retrieve the id_instance which needs to be copied
           SELECT @id_instance_parent = id_instance_parent,
                       @tx_instance_status = tx_status
           FROM @newInstances
           WHERE id_instance_temp = @id_instance_temp

           -- copy
           INSERT t_recevent_inst
           SELECT id_event, 
                       id_arg_interval,
                       @id_billgroup_child, 
                       dbo.GetBillingGroupAncestor(@id_billgroup_child), 
                       dt_arg_start, 
                       dt_arg_end,
                       b_ignore_deps, 
                       dt_effective, 
                       tx_status
           FROM t_recevent_inst
           WHERE id_instance = @id_instance_parent

           -- update @newInstances with the id_instance_child
           SET @id_instance_child = @@IDENTITY
           UPDATE @newInstances
           SET id_instance_child = @id_instance_child
           WHERE id_instance_temp = @id_instance_temp

                        /* copy the rows in t_recevent_run for id_instance_parent */
                         

	          	-- Declare @newRuns
	          	DECLARE @newRuns TABLE (id_run_temp INT IDENTITY(1000,1) NOT NULL,
	                                          	         id_run_parent INT, 
		                                             id_run_child INT,
		                                             tx_type VARCHAR(14), 
		                                             dt_start DATETIME)
	
	          	-- populate @newRuns with the parent rows
	          	INSERT @newRuns
	          	SELECT id_run,
	             	NULL,
	                      tx_type,
	                     dt_start
	          FROM t_recevent_run
	          WHERE id_instance = @id_instance_parent
	
	          --  set the count of @newRuns
	          SELECT @newRunsCount = COUNT(id_run_temp) 
	          FROM @newRuns
	
       	          IF (@newRunsCount > 0)
	              BEGIN
	                  SELECT @min_id_run_temp = MIN(id_run_temp)
                              FROM @newRuns

                              SET @id_run_temp = @min_id_run_temp
	            
	                  WHILE (@id_run_temp < (@min_id_run_temp + @newRunsCount))
	                      BEGIN
	                          -- retrieve the id_run which needs to be copied
		              SELECT @id_run_parent = id_run_parent
		              FROM @newRuns
		              WHERE id_run_temp = @id_run_temp
	   
	                          -- get the run id for the child
	                          EXEC GetCurrentID 'receventrun', @id_run_child OUTPUT
	
	                          -- copy
	                          INSERT t_recevent_run
	                          SELECT @id_run_child, @id_instance_child, 
	                                       tx_type, id_reversed_run, tx_machine, 
	                                       dt_start, dt_end, tx_status, tx_detail
	                          FROM t_recevent_run
	                          WHERE id_run = @id_run_parent
	
	                           -- update @newRuns with the id_run_child
	                           UPDATE @newRuns
	                           SET id_run_child = @id_run_child
	                           WHERE id_run_temp = @id_run_temp
	
	                          -- increment @id_run_temp
	                          SET @id_run_temp = @id_run_temp + 1
	
	                      END  -- the inner while loop ends here
	                      
	                      /*
	                          Get the @id_run_parent_out and @id_run_child_out. This logic must remain 
	                          the same as the logic in the 'DetermineReversibleEvents'  StoredProc which
	                          calculates 'RunIDToReverse'       
	                      */
	                    
	                      IF (@tx_instance_status = 'Succeeded' OR 
	                          @tx_instance_status = 'Failed')
	                      BEGIN
	                           SELECT @id_run_parent_out = @id_run_parent,
	                                       @id_run_child_out = @id_run_child
			   FROM @newRuns nr
			   WHERE tx_type = 'Execute' AND
			               dt_start IN (SELECT MAX(dt_start) 
			                                  FROM @newRuns)
	
	                            -- update @newInstances with the appropriate parent run and child run
	                            UPDATE @newInstances
	                            SET id_run_parent = @id_run_parent_out,
	                                   id_run_child = @id_run_child_out
	                            WHERE id_instance_temp = @id_instance_temp
	                      END
	                      
	
	                      /* Copy t_recevent_run_details data for the new billing group */
                                  IF EXISTS (SELECT id_run 
                                                  FROM t_recevent_run_details rd
                                                  INNER JOIN @newRuns nr ON nr.id_run_parent = rd.id_run)
                                     BEGIN       
		                INSERT INTO t_recevent_run_details(id_run,
						                          tx_type,
						                          tx_detail,
						                          dt_crt)
  	                            SELECT nr.id_run_child,
			                rd.tx_type,
			                rd.tx_detail,
			                rd.dt_crt
		               FROM t_recevent_run_details rd
		               INNER JOIN @newRuns nr ON nr.id_run_parent = rd.id_run 
                                    END 
	
	                      /* Copy t_recevent_run_batch data for the new billing group  */
                                  IF EXISTS (SELECT id_run 
                                                  FROM t_recevent_run_batch rb
                                                  INNER JOIN @newRuns nr ON nr.id_run_parent = rb.id_run)	
                                  BEGIN	        
                                       INSERT INTO t_recevent_run_batch(id_run, tx_batch_encoded)
		               SELECT nr.id_run_child, rb.tx_batch_encoded
		               FROM t_recevent_run_batch rb
		               INNER JOIN @newRuns nr ON nr.id_run_parent = rb.id_run
                                  END

                               DELETE @newRuns
	
	              END

           -- increment @id_instance_temp
           SET @id_instance_temp = @id_instance_temp + 1
       END

   SET @status = 0
   SELECT * FROM @newInstances

   -- COMMIT   
   
         