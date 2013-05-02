
%%INSERT_INTO_CLAUSE%%
SELECT 
/*  __GET_INITIAL_DEBIT_CORRECTION_CANDIDATES__ */
	'DebitCorrection' as c_RCActionType,
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
/*  Debit Correction Rule: The system ignores retroactive changes to payer when */
/*  giving corrections for advance charges.  So don't adjust the list of payers. */
/*  End Advance Correction Rule */
/*  Consider all recurring charge intervals of the appropriate cycle */
INNER JOIN t_pc_interval rci ON rci.id_cycle=tmp.rci_id_cycle
/*  Debit Correction Rules for initial charges:  */
/*  1) Correct only charges that have already been billed (those */
/*  with a start date prior to the current billing interval start date). */
/*  Note that an advance charge that has been billed could start in the current */
/*  bill interval, however an initial charge that has been bill must have started prior */
/*  to the current bill interval. */
/*  2) Valid time interval for UDRC value intersects the recurring charge interval  */
/*  3) Charge is billed by payer from history who is (valid time) effective */
/*   at the end of the recurring charge interval. */
/*  4) Charge is generated for the originating account in effect at the end of the */
/*  recurring charge interval. */
/*  5) Subscriptions intersect recurring charge interval */
  AND
  rci.dt_start < tmp.b_dt_start
  AND 
  rci.dt_end >= tmp.v_vt_start AND rci.dt_start <= tmp.v_vt_end
	AND 
	rci.dt_end BETWEEN tmp.p_vt_start AND tmp.p_vt_end
	AND 
	rci.dt_end BETWEEN tmp.o_vt_start AND tmp.o_vt_end
  AND
  rci.dt_start <= tmp.s_dt_end1 AND rci.dt_end >= tmp.s_dt_start
/*  End Debit Correction Rule */
/*  Debit Correction Rule for initial charges:  */
/*  1) Recurring charge interval begins prior to end of bill interval */
/*  2) Subscription starts in bill interval or originator changes during bill interval. */
/*  3) Correction is billed using payment history version that was (transaction time) */
/*  effective at the time the adapter for interval in which the charge being corrected was run */
/*  4) Correction is billed using originator history version that was (transaction time) */
/*  effective at the time the adapter for interval in which the charge being corrected was run */
INNER JOIN t_usage_interval billed ON billed.id_usage_cycle=tmp.b_id_usage_cycle
  AND 
  rci.dt_start < billed.dt_end
  AND
  (
  tmp.s_dt_start BETWEEN billed.dt_start AND billed.dt_end
  OR
	(tmp.o_vt_start BETWEEN billed.dt_start AND billed.dt_end AND tmp.o_tt_start BETWEEN billed.dt_start AND billed.dt_end)
  )
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
/*  End Debit Correction Rule */
WHERE
/*  Debit Correction Rule:  */
/*  Only generate corrections for modifications made during the current bill interval to */
/*  state that is "currently" effective */
tmp.prev_run_vt_start < tmp.v_tt_start AND tmp.run_vt_start >= tmp.v_tt_start 
AND tmp.v_tt_end = dbo.MTMaxDate()
/*  Debit Correction Rule: */
/*  If prorating on activation, only require that the valid time interval  */
/*  ends after the start of subscription.  Note that we can't assume that the unit value */
/*  interval actually intersects the subscription because that would require using the */
/*  end date of the subscription which amounts to using future information about subs */
/*  (which we have agreed NOT to do). */
  AND (tmp.b_prorate_on_activate = 'N' OR tmp.s_dt_start <= tmp.v_vt_end)
/* ------- End UDRC Stuff */
/*  End Debit Correction Rule */
