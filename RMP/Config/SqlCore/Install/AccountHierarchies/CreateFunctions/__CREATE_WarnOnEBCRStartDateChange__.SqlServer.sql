
CREATE FUNCTION WarnOnEBCRStartDateChange
(
  @id_sub INT -- subscription ID
)
RETURNS INT  -- 1 if a warning should be raised, 0 otherwise
AS
BEGIN

  DECLARE @isGroup INT
  SELECT @isGroup = CASE WHEN id_group IS NULL THEN 0 ELSE 1 END
  FROM t_sub 
  WHERE id_sub = @id_sub

  IF @@ROWCOUNT = 0
    RETURN -1

    -- checks to see if the subscription is associated with an EBCR RC
    -- and that the EBCR cycle type and the subscriber's billing cycle
    -- are such that the start date would be used in derivations
  IF @isGroup = 0 AND EXISTS 
    (
      SELECT *
      FROM t_sub sub 
      INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
      INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
      INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = sub.id_acc
      INNER JOIN t_usage_cycle payeecycle ON payeecycle.id_usage_cycle = auc.id_usage_cycle
      WHERE 
        rc.tx_cycle_mode = 'EBCR' AND
        rc.b_charge_per_participant = 'N' AND
        sub.id_sub = @id_sub AND
        plmap.id_paramtable IS NULL AND
        payeecycle.id_cycle_type = 1 AND -- the subscriber is Monthly
        rc.id_cycle_type IN (7, 8, 9) -- and the EBCR cycle type is Quarterly, SemiAnnual, or Annually
    )
      RETURN 1 -- warn the user!
  -- checks to see if the group sub is associated with an EBCR RC
  -- and that the EBCR cycle type and the receiver's payer's billing cycle
  -- are such that the start date would be used in derivations
  ELSE IF @isGroup = 1 AND EXISTS 
    (
      SELECT NULL
      FROM t_sub sub
      INNER JOIN t_gsub_recur_map gsrm ON gsrm.id_group = sub.id_group 
      INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
      INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
      INNER JOIN t_payment_redirection pay ON 
        pay.id_payee = gsrm.id_acc AND
        -- checks all payer's who overlap with the group sub
        pay.vt_end >= sub.vt_start AND
        pay.vt_start <= sub.vt_end
      INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
      INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle = auc.id_usage_cycle
      WHERE 
        rc.tx_cycle_mode = 'EBCR' AND
        rc.b_charge_per_participant = 'N' AND
        sub.id_sub = @id_sub AND
        plmap.id_paramtable IS NULL AND
        payercycle.id_cycle_type = 1 AND -- the subscriber is Monthly
        rc.id_cycle_type IN (7, 8, 9) -- and the EBCR cycle type is Quarterly, SemiAnnually, or Annually
    )
      RETURN 1 -- warn the user!

  RETURN 0 -- don't warn
END
				