
/* ===========================================================
Attempts to 'HardClose' the given billing group.

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : @id_billgroup does not exist
   -3 : The billgroup is already HardClosed
   -4 : This is the last billing group to be hard closed and there are unassigned accounts
          which are not hard closed
   -5 : Could not update billing group status to 'H'
=========================================================== */
CREATE PROCEDURE HardCloseBillingGroup
(
  @id_billgroup INT,            -- specific billing group to hard close
  @status INT OUTPUT         -- return code: 0 is successful 
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
  DECLARE @intervalID INT
 
  SELECT @billingGroupStatus = status,
              @intervalID = id_usage_interval
  FROM vw_all_billing_groups_status
  WHERE id_billgroup = @id_billgroup

  IF (@billingGroupStatus = 'H')
     BEGIN
       SET @status = -3
       ROLLBACK
       RETURN 
     END
 
  -- If this is the last billing group which is being hard closed for the interval 
  -- then make sure that all unassigned accounts have their status set to 'H'
  DECLARE @numHardClosedBillingGroups INT
  DECLARE @numBillingGroups INT
  DECLARE @lastBillingGroup INT

  SET @lastBillingGroup = 0
  
  SELECT @numHardClosedBillingGroups = COUNT(id_billgroup)
  FROM vw_all_billing_groups_status
  WHERE id_usage_interval = @intervalID AND
              status = 'H'

  SELECT @numBillingGroups = COUNT(id_billgroup)
  FROM vw_all_billing_groups_status
  WHERE id_usage_interval = @intervalID
 
  IF (@numHardClosedBillingGroups = (@numBillingGroups - 1))
  BEGIN
     SET @lastBillingGroup = 1
  END

  IF (@lastBillingGroup = 1)
     BEGIN
	 
	    /* ESR-5236 use the underlying tables instead of views vw_unassigned_accounts and vw_paying_accounts */ 
        IF EXISTS (SELECT aui.id_acc as AccountID               
					FROM t_acc_usage_interval aui
						INNER JOIN t_account_mapper amap ON amap.id_acc = aui.id_acc
						INNER JOIN t_namespace nmspace ON nmspace.nm_space = amap.nm_space
					WHERE nmspace.tx_typ_space = 'system_mps' AND tx_status != 'H'  
						and (aui.id_acc NOT IN ( SELECT bgm.id_acc 
													FROM dbo.t_billgroup_member AS bgm 
													INNER JOIN dbo.t_billgroup AS bg ON bg.id_billgroup = bgm.id_billgroup 
													       AND bg.id_usage_interval = aui.id_usage_interval
												)
							 )
                            and aui.id_usage_interval = @intervalID
							GROUP BY aui.id_usage_interval, aui.id_acc, aui.tx_status
				  )
           
          BEGIN
	  SET @status = -4
	  ROLLBACK
	  RETURN 
          END                  
     END
  
  -- Update the billing group status to 'H'
  EXEC UpdateBillingGroupStatus @id_billgroup, 'H'
  
  -- Update the status in t_usage_interval to hard closed, if possible.
  DECLARE @status1 INT
  EXEC UpdIntervalStatusToHardClosed @intervalID, 0, @status1 OUTPUT
  
  IF (@@ERROR != 0)
    BEGIN
       SELECT @status = -5
       ROLLBACK
       RETURN
    END   
 
  SET @status = 0 -- success
  COMMIT

END
  