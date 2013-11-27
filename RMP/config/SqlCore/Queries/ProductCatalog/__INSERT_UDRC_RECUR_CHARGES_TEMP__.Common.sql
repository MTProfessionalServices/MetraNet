
%%INSERT_INTO_CLAUSE%%
SELECT 
/*  __INSERT_UDRC_RECUR_CHARGES_TEMP__ */
/*  Get candidates for individual subscriptions and per-participant group charges */
sub.id_acc id_acc,
sub.id_sub id_sub,
dbo.MTMinDate() o_vt_start,
dbo.MTMaxDate() o_vt_end,
dbo.MTMinDate() o_tt_start,
dbo.MTMaxDate() o_tt_end,
'N' as b_per_subscription,
pay.id_payer id_payer,
pay.tt_start p_tt_start,
pay.tt_end p_tt_end,
pay.vt_start p_vt_start,
pay.vt_end p_vt_end,
binterval.dt_start b_dt_start, 
binterval.dt_end b_dt_end,
binterval.id_interval as b_id_usage_interval,
nextbinterval.dt_start nb_dt_start,
/* ESR-2969 */
COALESCE(dbo.AddSecond(nabinterval.dt_effective), nextbinterval.dt_start) as nb_dt_start_corrected,
nextbinterval.dt_end nb_dt_end,
nextbinterval.id_interval as nb_id_usage_interval,
typemap.id_pi_instance, 
typemap.id_pi_template,
typemap.id_po,
sub.dt_start s_dt_start,
sub.dt_end s_dt_end,
dbo.mtendofday(sub.dt_end) s_dt_end1,
binterval.id_usage_cycle b_id_usage_cycle,
cycle.id_usage_cycle rci_id_cycle,
recinstance.b_advance,
recinstance.b_prorate_on_activate,
recinstance.b_prorate_instantly,
recinstance.b_prorate_on_deactivate,
recinstance.b_fixed_proration_length,
fixedlen.n_proration_length,
value.n_value v_value,
value.vt_start v_vt_start,
value.vt_end v_vt_end,
value.tt_start v_tt_start,
value.tt_end v_tt_end,
recinstance.n_rating_type as n_rating_type,
rei.id_event as run_id_event,
rer.dt_start as run_vt_start,
CASE WHEN prevrer.prev_run_vt_start IS NULL THEN {ts '2038-01-01 00:00:00'} ELSE prevrer.prev_run_vt_start END as prev_run_vt_start
%%INTO_CLAUSE%%
FROM 
t_usage_interval binterval
/* ESR-2969 */
INNER JOIN t_acc_usage_interval abinterval ON binterval.id_interval = abinterval.id_usage_interval
INNER JOIN t_acc_usage_interval nabinterval ON abinterval.id_acc = nabinterval.id_acc 
INNER JOIN t_usage_interval nextbinterval ON nextbinterval.id_interval=nabinterval.id_usage_interval AND COALESCE(dbo.AddSecond(nabinterval.dt_effective), nextbinterval.dt_start) = dbo.AddSecond(binterval.dt_end)
/*  DB: Can't assume cycle is constant when getting next interval.  Must go to t_acc_usage_interval */
/* INNER JOIN t_usage_interval nextbinterval ON nextbinterval.id_usage_cycle=binterval.id_usage_cycle */
/*   AND */
/*  nextbinterval.dt_start = dbo.addsecond(binterval.dt_end) */
/* INNER JOIN t_acc_usage_interval abinterval ON binterval.id_interval = abinterval.id_usage_interval */
INNER JOIN t_billgroup_member bg ON bg.id_acc = abinterval.id_acc
INNER JOIN t_payment_redir_history pay ON pay.id_payer = abinterval.id_acc
/*  Get subscriptions for the payees throughout history */
INNER JOIN t_vw_effective_subs sub ON sub.id_acc = pay.id_payee
INNER JOIN	t_pl_map typemap ON sub.id_po = typemap.id_po
INNER JOIN t_recur recinstance ON typemap.id_pi_instance=recinstance.id_prop

/*  determines the charge cycle */
/* ESR-2969 */
/*DB: Use cycle of next interval (maybe not the right thing for Arrears?)*/
/* INNER JOIN t_acc_usage_cycle payercycle ON payercycle.id_acc = pay.id_payer */
INNER JOIN t_usage_cycle cycle ON cycle.id_usage_cycle = 
  CASE WHEN recinstance.tx_cycle_mode = 'Fixed' THEN recinstance.id_usage_cycle
       WHEN (recinstance.tx_cycle_mode = 'BCR Constrained') THEN nextbinterval.id_usage_cycle /* DB: payercycle.id_usage_cycle */
       WHEN (recinstance.tx_cycle_mode = 'EBCR') THEN 
       /* ESR-2969 */
         dbo.DeriveEBCRCycle(nextbinterval.id_usage_cycle /* DB:payercycle.id_usage_cycle*/, sub.dt_start, recinstance.id_cycle_type)
    ELSE NULL
  END
INNER JOIN t_usage_cycle_type fixedlen ON fixedlen.id_cycle_type = cycle.id_cycle_type
/* ------- Begin UDRC Stuff */
INNER JOIN t_recur_value value ON recinstance.id_prop=value.id_prop AND sub.id_sub=value.id_sub
/* ------- End UDRC Stuff */
INNER JOIN t_recevent_inst rei ON rei.id_arg_interval=binterval.id_interval AND rei.id_arg_billgroup=bg.id_billgroup
INNER JOIN t_recevent_run rer ON rei.id_instance=rer.id_instance
/* Here we need to know when the adapter ran for its previous interval (this may not exist) */
LEFT OUTER JOIN (
  select
  prevbinterval.id_usage_cycle, prevbinterval.dt_end, prevbgm.id_acc, prevrei.id_event,
  max(prer.dt_start) as prev_run_vt_start
  from
  t_usage_interval prevbinterval  
  INNER JOIN t_billgroup prevbg ON prevbg.id_usage_interval=prevbinterval.id_interval
  INNER JOIN t_billgroup_member prevbgm ON prevbg.id_billgroup=prevbgm.id_billgroup 
  INNER JOIN t_recevent_inst prevrei ON prevrei.id_arg_interval=prevbinterval.id_interval AND prevrei.id_arg_billgroup=prevbg.id_billgroup
  INNER JOIN t_recevent_run prer ON prer.id_instance=prevrei.id_instance
  group by prevbinterval.id_usage_cycle, prevbinterval.dt_end, prevbgm.id_acc, prevrei.id_event
  ) prevrer ON prevrer.id_usage_cycle=binterval.id_usage_cycle AND 
  dbo.addsecond(prevrer.dt_end) = binterval.dt_start AND 
  prevrer.id_acc=abinterval.id_acc AND 
  prevrer.id_event=rei.id_event
WHERE
rer.id_run=%%ID_RUN%%
AND
typemap.id_paramtable IS NULL
AND
(
  recinstance.b_charge_per_participant = 'Y'
  OR
  sub.b_group = 'N'
)
AND 
typemap.id_pi_type = %%RECUR_CHARGE_TYPE%%
AND 
recinstance.b_advance= '%%B_ADVANCE%%'
AND
binterval.id_interval=%%INTERVAL_ID%%
AND
bg.id_billgroup=%%BILLING_GROUP_ID%%
AND
value.tt_end = dbo.MTMaxDate()
