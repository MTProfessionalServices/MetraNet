
%%INSERT_INTO_CLAUSE%%
SELECT 
/*  __GET_INITIAL_CORRECTION_CANDIDATES__ */
	'InitialCorrection' as c_RCActionType,
	tmp.id_acc as c__AccountID,
 tmp.id_payer as c__PayingAccount,
	tmp.b_dt_start as c_BillingIntervalStart, 
	tmp.b_dt_end as c_BillingIntervalEnd,
	tmp.nb_dt_start as c_NextBillingIntervalStart,
	tmp.nb_dt_end as c_NextBillingIntervalEnd,
	tmp.id_pi_instance as c__PriceableItemInstanceID, 
	tmp.id_pi_template as c__PriceableItemTemplateID,
	tmp.id_po as c__ProductOfferingID,
	rci.dt_start as c_RCIntervalStart, 
	rci.dt_end as c_RCIntervalEnd, 
	tmp.id_sub AS c__SubscriptionID,
	tmp.s_dt_start AS c_SubscriptionStart,
	tmp.s_dt_end AS c_SubscriptionEnd,
	/* For corrections, don't intersect the recurring charge interval with the  */
	/* subscription end; since charges being corrected cannot have been billed */
	/* in the last interval and therefore would have been billed in full.  Furthermore, */
	/* a retroactive subscription end might have changed the state that was in effect */
	/* then and we don't want to be polluted by that. */
	dbo.MTMaxOfTwoDates(rci.dt_start, tmp.s_dt_start) as c_RCIntervalSubscriptionStart,
	rci.dt_end as c_RCIntervalSubscriptionEnd,
	tmp.b_advance as c_Advance,
	tmp.b_prorate_on_activate as c_ProrateOnSubscription,
  tmp.b_prorate_instantly as c_ProrateInstantly,
	tmp.b_prorate_on_deactivate as c_ProrateOnUnsubscription,
	case tmp.b_fixed_proration_length when 'Y' then tmp.n_proration_length else 0 end as c_ProrationCycleLength,
	billed.dt_end as c_BilledRateDate,
 tmp.p_tt_end candidate_tt_end,
	tmp.o_tt_end candidate_originator_tt_end,
	tmp.b_per_subscription b_per_subscription,
  tmp.v_value as c_UnitValue,
  tmp.v_vt_start as c_UnitValueStart,
  tmp.v_vt_end as c_UnitValueEnd,
  tmp.n_rating_type as c_RatingType,
	tmp.run_id_event,
	tmp.run_vt_start
%%INTO_CLAUSE%%
FROM 
%%%TEMP_TABLE_PREFIX%%%tmp_rc_advance_1 tmp
/*  Initial Correction Rule: The system ignores retroactive changes to payer when */
/*  giving corrections for advance charges.  So don't adjust the list of payers.  Use */
/*  the history in effect when the charge being corrected was created. */
/*  End Advance Correction Rule */
/*  Consider all recurring charge intervals of the appropriate cycle */
INNER JOIN t_pc_interval rci ON rci.id_cycle=tmp.rci_id_cycle
/*  Initial Correction Rules:  */
/*  1) Correct only charges that have already been billed (those */
/*  with a start date prior to the current billing interval start date;  */
/*  remember initial charges are those that start prior to the end of the */
/*  first bill interval after subscription). */
/*  2) Valid time interval for UDRC value intersects the recurring charge interval  */
/*  3) Charge is billed by payer from history who is (valid time) effective */
/*   at the end of the recurring charge interval. */
/*  4) Charge is generated for the originating account in effect at the end of the */
/*  recurring charge interval. */
  AND
  rci.dt_start < tmp.b_dt_start
  AND 
  rci.dt_end >= tmp.v_vt_start AND rci.dt_start <= tmp.v_vt_end
	AND 
	rci.dt_end BETWEEN tmp.p_vt_start AND tmp.p_vt_end
	AND 
	rci.dt_end BETWEEN tmp.o_vt_start AND tmp.o_vt_end
/*  End Initial Correction Rule */
/*  Initial Correction Rule: Recurring charge interval  */
/*   Begins prior to the end of the billing interval that contains the subscription start. */
/*  N.B. The billing interval containing the subscription start is the */
/*  interval in which the initial charge is billed. */
/*  Corrections always refer to the payment history in effect when the charge being corrected */
/*  was billed.  This is payment history at the date the adapter for that interval was last run. */
/*  Corrections always refer to the originator history in effect when the charge being corrected */
/*  was billed.  This is originator history at the date the adapter for that interval was last run. */
INNER JOIN t_usage_interval billed ON billed.id_usage_cycle=tmp.b_id_usage_cycle
  AND 
  (
  tmp.s_dt_start BETWEEN billed.dt_start AND billed.dt_end
  OR
  (tmp.o_vt_start BETWEEN billed.dt_start AND billed.dt_end AND tmp.o_tt_start BETWEEN billed.dt_start AND billed.dt_end)
  )
  AND
  billed.dt_end >= rci.dt_start
	AND
	billed.dt_end < tmp.b_dt_start
INNER JOIN t_billgroup_member bgm ON bgm.id_acc=tmp.id_payer
INNER JOIN t_billgroup bg ON bg.id_billgroup=bgm.id_billgroup AND bg.id_usage_interval=billed.id_interval
INNER JOIN t_recevent_inst rei ON rei.id_event=tmp.run_id_event AND rei.id_arg_interval=billed.id_interval AND rei.id_arg_billgroup=bg.id_billgroup
INNER JOIN (
  select
  rer.id_instance,
  max(rer.dt_start) as run_vt_start
  from
  t_recevent_run rer
  group by rer.id_instance
  ) rer ON rer.id_instance=rei.id_instance
  AND
  rer.run_vt_start BETWEEN tmp.p_tt_start AND tmp.p_tt_end
  AND
  rer.run_vt_start BETWEEN tmp.o_tt_start AND tmp.o_tt_end
/*  End Initial Correction Rule */
/*  Initial Correction Rule */
/*  1) Only select RCI/Unit Value intervals for correction if the current */
/*     version of history has changed the value at any time during the intersection */
/*     of the RCI and Unit Value interval */
/*  TODO: Fix bug, if the new version of history has multiple versions that are different  */
/*  from the one we are correcting */
INNER JOIN t_recur_value rv ON rv.id_prop=tmp.id_pi_instance 
  AND 
  rv.id_sub=tmp.id_sub
  AND rv.vt_start <= tmp.v_vt_end AND tmp.v_vt_start <= rv.vt_end
  AND rv.vt_start <= rci.dt_end AND rci.dt_start <= rv.vt_end
  AND rv.n_value <> tmp.v_value
  AND rv.tt_end = dbo.MTMaxDate()
/*  End Initial Correction Rule */
WHERE
/*  Initial Correction Rule:  */
/*  Only generate corrections for modifications made during the current bill interval to */
/*  state that was in effect for a prior interval */
tmp.prev_run_vt_start < tmp.v_tt_end AND tmp.run_vt_start >= tmp.v_tt_end 
AND tmp.prev_run_vt_start >= tmp.v_tt_start
/*  Initial Correction Rule: */
/*  If prorating on activation, only require that the valid time interval  */
/*  ends after the start of subscription.  Note that we can't assume that the unit value */
/*  interval actually intersects the subscription because that would require using the */
/*  end date of the subscription which amounts to using future information about subs */
/*  (which we have agreed NOT to do). */
  AND (tmp.b_prorate_on_activate = 'N' OR tmp.s_dt_start <= tmp.v_vt_end)
/*  End Initial Correction Rule */
