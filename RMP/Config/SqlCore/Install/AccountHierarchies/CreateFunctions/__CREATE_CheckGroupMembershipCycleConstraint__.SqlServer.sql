
CREATE FUNCTION CheckGroupMembershipCycleConstraint
(
  @dt_now DATETIME, -- system date
  @id_group INT     -- group ID to check
)
RETURNS INT  -- 1 for success, otherwise negative decimal error code 
AS
BEGIN

  -- this function enforces the business rule given in CR9906
  -- a group subscription to a PO containing a BCR priceable item
  -- should only have member's with payers that have a usage cycle
  -- that matches the one specified by the group subscription.
  -- at any point in time, this cycle consistency should hold true. 

  -- looks up the PO the group is subscribed to
  DECLARE @id_po INT
  SELECT @id_po = sub.id_po
  FROM t_group_sub gs
  INNER JOIN t_sub sub ON sub.id_group = gs.id_group
  WHERE gs.id_group = @id_group

  -- this check only applies to PO's that contain a BCR priceable item
  IF dbo.POContainsBillingCycleRelative(@id_po) = 1 -- true
  BEGIN
    
    -- attempts to find a usage cycle mismatch for the member's payers of the group sub
    -- ideally there should be none
    DECLARE @violator INT
    SELECT TOP 1 @violator = gsm.id_acc
    FROM t_gsubmember gsm
    INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
    INNER JOIN t_sub sub ON sub.id_group = gs.id_group
    INNER JOIN t_payment_redirection payer ON 
      payer.id_payee = gsm.id_acc AND
      -- checks all payer's who overlap with the group sub
      payer.vt_end >= sub.vt_start AND
      payer.vt_start <= sub.vt_end
    INNER JOIN t_acc_usage_cycle auc ON
      auc.id_acc = payer.id_payer AND
      -- cycle mismatch
      auc.id_usage_cycle <> gs.id_usage_cycle
    WHERE 
      -- checks only the requested group
      gs.id_group = @id_group AND
      -- only consider current or future group subs
      -- don't worry about group subs in the past
      ((@dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
       (sub.vt_start > @dt_now))

    IF @@rowcount > 0
      -- MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH
      RETURN -486604730
  END
  
  -- success
  RETURN 1
END
  