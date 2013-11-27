
  AND EXISTS
  (
    /* returns true if a group subscription should be processed as "part of" the current billing group */
    /* the "part of" relationship is defined as a gsub having a member that has at least one payer */
    /* who pays during the effective discount period and is part of the given billing group. */
    /* account constraints ensure that if one payer is found all members' payers for the group */
    /* sub will be part of the billing group */
    SELECT 1
    FROM t_gsubmember gsm
    INNER JOIN t_payment_redir_history pay ON pay.id_payee = gsm.id_acc
    INNER JOIN t_billgroup_member bgmember ON bgmember.id_acc = pay.id_payer
    WHERE 
      gsm.id_group = gsub.id_group AND
      bgmember.id_billgroup = %%ID_BILLGROUP%% AND
      /* only includes payers who where valid time effective at the end discount interval */
      dbo.MTMaxOfTwoDates(di.dt_end, sub.vt_end) BETWEEN pay.vt_start AND pay.vt_end AND
      /* only include the transaction time history that was in effect at the end of the billing interval */
      /* NOTE: because of this retroactive payment changes will be ignored */
      dbo.MTMinOfTwoDates(di.dt_end, sub.vt_end) BETWEEN pay.tt_start AND pay.tt_end)
