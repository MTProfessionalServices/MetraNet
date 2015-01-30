
CREATE FUNCTION CheckGroupReceiverEBCRConstraint
(
  @dt_now DATETIME, -- system date
  @id_group INT     -- group ID to check
)
RETURNS INT  -- 1 for success, negative HRESULT for failure
AS
BEGIN
  -- checks to see if a group subscription and all of its'
  -- receivers' payers comply with the EBCR payer cycle constraints:
  -- 1) that all receivers' payers must have the same billing cycle
  -- 2) that billing cycle must be EBCR compatible.

  DECLARE @results TABLE 
  (
    id_acc INT, -- receiver account
    id_usage_cycle INT, -- payer's cycle
    b_compatible INT -- EBCR compatibility: 1 or 0
  )

  -- store intermediate results away for later use since different groupings will need to be made
  INSERT INTO @results
  SELECT gsrm.id_acc, payercycle.id_usage_cycle, dbo.CheckEBCRCycleTypeCompatibility(payercycle.id_cycle_type, rc.id_cycle_type)
  FROM t_gsub_recur_map gsrm
  INNER JOIN t_group_sub gs ON gs.id_group = gsrm.id_group
  INNER JOIN t_sub sub ON sub.id_group = gs.id_group
  INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po AND
                               plmap.id_pi_instance = gsrm.id_prop
  INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
  INNER JOIN t_payment_redirection payer ON 
    payer.id_payee = gsrm.id_acc AND
    -- checks all payer's who overlap with the group sub
    payer.vt_end >= sub.vt_start AND
    payer.vt_start <= sub.vt_end
  INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = payer.id_payer
  INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle = auc.id_usage_cycle
  WHERE 
    rc.tx_cycle_mode = 'EBCR' AND
    rc.b_charge_per_participant = 'N' AND
    -- checks only the requested group
    gs.id_group = @id_group AND
    plmap.id_paramtable IS NULL AND
    -- only consider receivers based on wall-clock transaction time
    @dt_now BETWEEN gsrm.tt_start AND gsrm.tt_end AND
    -- TODO: it would be better if we didn't consider subscriptions that ended
    --       in a hard closed interval so that retroactive changes would be properly guarded.
    -- only consider current or future group subs
    -- don't worry about group subs in the past
    ((@dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
     (sub.vt_start > @dt_now))

  -- checks that receivers' payers are compatible with the EBCR cycle type
  IF EXISTS 
  (
    SELECT NULL
    FROM @results
    WHERE b_compatible = 0
    GROUP BY id_acc
  )
    RETURN -289472441 -- MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_RECEIVER


  -- checks that only one payer cycle was found
  DECLARE @count INT
  SELECT @count = COUNT(*)
  FROM
  ( 
    SELECT 1 a
    FROM @results
    GROUP BY id_usage_cycle 
  ) cycles
  IF (@count > 1)
    RETURN -289472440 -- MTPCUSER_EBCR_RECEIVERS_CONFLICT_WITH_EACH_OTHER

  RETURN 1 -- success
END
  