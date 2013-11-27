
CREATE FUNCTION WarnOnEBCRMemberStartDateChang
(
  @id_sub INT, -- subscription ID
  @id_acc INT  -- member account ID
)
RETURNS INT  -- 1 if a warning should be raised, 0 otherwise
AS
BEGIN

  -- checks to see if the subscription is associated with an EBCR RC
  -- and that the EBCR cycle type and the subscriber's billing cycle
  -- are such that the start date would be used in derivations
  IF EXISTS 
    (
      SELECT *
      FROM t_sub sub 
      INNER JOIN t_group_sub gs ON gs.id_group = sub.id_group
      INNER JOIN t_gsubmember gsm ON gsm.id_group = gs.id_group
      INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
      INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
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
        sub.id_sub = @id_sub AND
        gsm.id_acc = @id_acc AND
        plmap.id_paramtable IS NULL AND
        payercycle.id_cycle_type = 1 AND -- the subscriber is Monthly
        rc.id_cycle_type IN (7, 8, 9) -- and the EBCR cycle type is either Quarterly, Semiannually, or Annually
    )
      RETURN 1 -- warn the user!

  RETURN 0 -- don't warn
END
				