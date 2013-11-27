
/* ===========================================================
Attempts to 'Open' the given billing group.

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : @id_billgroup does not exist
   -3 : The billgroup is not soft closed
   -4 : Unable to find _StartRoot instance for @id_billgroup
   -5 : Not all instances, which depend on the billing group, have been reversed successfully
   -6 : Could not update billing group status to 'C'
=========================================================== */
CREATE PROCEDURE OpenBillingGroup
(
  @dt_now DATETIME,     -- MetraTech system date
  @id_billgroup INT,        -- specific billing group to reopen, the billing group must be soft-closed
  @ignoreDeps INT,         -- whether to ignore the reverse dependencies for re-opening the billing group
  @pretend INT,                -- if pretend is true, the billing group is not actually reopened
  @status INT OUTPUT     -- return code: 0 is successful
)
AS

BEGIN
  BEGIN TRAN

  SELECT @status = -1

  -- checks that the billing group exists
  IF NOT EXISTS (SELECT id_billgroup 
                          FROM t_billgroup
                          WHERE id_billgroup = @id_billgroup)
    BEGIN
       SET @status = -2
       ROLLBACK
       RETURN 
     END

  -- checks that the billing group is soft closed
  DECLARE @billingGroupStatus VARCHAR(1)
 
  SELECT @billingGroupStatus = status
  FROM vw_all_billing_groups_status
  WHERE id_billgroup = @id_billgroup

  IF (@billingGroupStatus != 'C')
     BEGIN
       SET @status = -3
       ROLLBACK
       RETURN 
     END
 
  --
  -- retrieves the instance ID of the start root event for the given billing group
  --
  DECLARE @id_instance INT
  SELECT @id_instance = inst.id_instance
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE
    -- event must be active
    evt.dt_activated <= @dt_now and
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    -- instance must match the given billing group
    inst.id_arg_billgroup = @id_billgroup AND
    evt.tx_name = '_StartRoot' AND
    evt.tx_type = 'Root'

  IF @id_instance IS NULL
  BEGIN
    -- start root instance was not found!
    SELECT @status = -4
    ROLLBACK
    RETURN
  END
  
  --
  -- checks start root's reversal dependencies
  --
  IF @ignoreDeps = 0
  BEGIN
    DECLARE @count INT

    SELECT @count = COUNT(*)
    FROM GetEventReversalDeps(@dt_now, @id_instance) deps
    WHERE deps.tx_status <> 'NotYetRun'

    IF @count > 0
    BEGIN
      -- not all instances, which depend on the billing group, have been reversed successfully
      SELECT @status = -5
      ROLLBACK
      RETURN
    END   
  END

  -- just pretending, so don't do the update
  IF @pretend != 0
  BEGIN
    SELECT @status = 0 -- success
    COMMIT
    RETURN
  END  

  EXEC UpdateBillingGroupStatus @id_billgroup, 'O'
  
  IF (@@ERROR != 0)
    BEGIN
       SELECT @status = -6
       ROLLBACK
       RETURN
    END  

   SET @status = 0 -- success
   COMMIT
 
END
  