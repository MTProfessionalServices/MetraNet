
CREATE FUNCTION IsBillingCycleUpdateProhibitedByGroupEBCR
(
  @dt_now DATETIME,
  @id_acc INT
)
RETURNS INT 
BEGIN

  -- checks if the account pays for a member of a group subscription
  -- associated with a Per Participant EBCR RC
  IF EXISTS 
  (
    SELECT NULL
    FROM t_gsubmember gsm
    INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
    INNER JOIN t_sub sub ON sub.id_group = gs.id_group
    INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
    INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
    INNER JOIN t_payment_redirection payer ON 
    payer.id_payee = gsm.id_acc AND
    -- checks all payer's who overlap with the group sub
    payer.vt_end >= sub.vt_start AND
    payer.vt_start <= sub.vt_end
    INNER JOIN t_acc_usage_cycle payercycle ON payercycle.id_acc = payer.id_payer
    WHERE 
      rc.tx_cycle_mode = 'EBCR' AND
      rc.b_charge_per_participant = 'Y' AND
      payer.id_payer = @id_acc AND
      plmap.id_paramtable IS NULL AND
      -- TODO: it would be better if we didn't consider subscriptions that ended
      --       in a hard closed interval so that retroactive changes would be properly guarded.
      -- only consider current or future group subs
      -- don't worry about group subs in the past
      ((@dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
       (sub.vt_start > @dt_now))
  )
    RETURN -289472439  -- MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_MEMBER


  -- checks if the account pays for a receiver of a group subscription
  -- associated with a Per Subscriber EBCR RC
  IF EXISTS
  (
    SELECT NULL
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
    INNER JOIN t_acc_usage_cycle payercycle ON payercycle.id_acc = payer.id_payer
    WHERE 
      rc.tx_cycle_mode = 'EBCR' AND
      rc.b_charge_per_participant = 'N' AND
      -- checks only the requested group
      payer.id_payer = @id_acc AND
      plmap.id_paramtable IS NULL AND
      -- only consider receivers based on wall-clock transaction time
      @dt_now BETWEEN gsrm.tt_start AND gsrm.tt_end AND
      -- TODO: it would be better if we didn't consider subscriptions that ended
      --       in a hard closed interval so that retroactive changes would be properly guarded.
      -- only consider current or future group subs
      -- don't worry about group subs in the past
      ((@dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
       (sub.vt_start > @dt_now))
  )
    RETURN -289472438  -- MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_RECEIVER
	
  RETURN 1 -- success, can update the billing cycle
END
  