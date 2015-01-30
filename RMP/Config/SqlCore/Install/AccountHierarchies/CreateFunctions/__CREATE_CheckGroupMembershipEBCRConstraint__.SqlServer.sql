

CREATE FUNCTION CheckGroupMembershipEBCRConstraint
(
  @dt_now DATETIME, -- system date
  @id_group INT     -- group ID to check
)
RETURNS INT  -- 1 for success, negative HRESULT for failure
AS
BEGIN

  -- checks to see if a group subscription and all of its
  -- members comply with EBCR payer cycle constraints:
  --   1) that for a member, all of its payers have the same billing cycle
  --   2) that this billing cycle is EBCR compatible.

  DECLARE @results TABLE 
  (
    id_acc INT, -- member account (payee)
    id_usage_cycle INT, -- payer's cycle
    b_compatible INT -- EBCR compatibility: 1 or 0
  )

  -- checks group member's payers
  INSERT INTO @results
  SELECT 
    pay.id_payee,
    payercycle.id_usage_cycle,
    dbo.CheckEBCRCycleTypeCompatibility(payercycle.id_cycle_type, rc.id_cycle_type)
  FROM t_group_sub gs
  INNER JOIN t_sub sub ON sub.id_group = gs.id_group
  INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
  INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
  INNER JOIN t_gsubmember gsm ON gs.id_group = gsm.id_group
  INNER JOIN t_payment_redirection pay ON 
    pay.id_payee = gsm.id_acc AND
    -- checks all payer's who overlap with the group sub
    pay.vt_end >= sub.vt_start AND
    pay.vt_start <= sub.vt_end
  INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
  INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle = auc.id_usage_cycle
  WHERE 
    rc.tx_cycle_mode = 'EBCR' AND
    rc.b_charge_per_participant = 'Y' AND
    gs.id_group = @id_group AND
    plmap.id_paramtable IS NULL AND
    -- TODO: it would be better if we didn't consider subscriptions that ended
    --       in a hard closed interval so that retroactive changes would be properly guarded.
    -- only consider current or future group subs
    -- don't worry about group subs in the past
    ((@dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
     (sub.vt_start > @dt_now))
  OPTION (FORCE ORDER)
 -- checks that members' payers are compatible with the EBCR cycle type
  IF EXISTS 
  (
    SELECT NULL
    FROM @results
    WHERE b_compatible = 0
  )
    RETURN -289472443 -- MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER

  -- checks for each member there is only one payer cycle across all payers
  IF EXISTS
  (
    SELECT NULL
    FROM @results r
    INNER JOIN @results r2 ON r2.id_acc = r.id_acc AND
                              r2.id_usage_cycle <> r.id_usage_cycle
  )
    RETURN -289472442 -- MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER

  RETURN 1 -- success
END
  