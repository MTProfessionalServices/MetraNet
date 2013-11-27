
%%INSERT_INTO_CLAUSE%%
SELECT 
/*  __GET_INITIAL_CREDIT_CANDIDATES__ */
	'Credit' as c_RCActionType,
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
	dbo.MTMaxOfTwoDates(rci.dt_start, dbo.addsecond(tmp.s_dt_end1)) as c_RCIntervalSubscriptionStart,
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
	tmp.run_id_event as run_id_event,
	tmp.run_vt_start as run_vt_start
%%INTO_CLAUSE%%
FROM 
%%%TEMP_TABLE_PREFIX%%%tmp_rc_advance_1 tmp
/*  Initial Credit Rule: The system ignores retroactive changes to payment when */
/*  giving credits for advance charges. */
/*  End Initial Credit Rule */
/*  Consider all recurring charge intervals of the appropriate cycle */
/* ESR-3073 use b_id_usage_cycle instead of rci_id_cycle *** BACKED OUT per CORE-2733 */
INNER JOIN t_pc_interval rci ON rci.id_cycle=tmp.rci_id_cycle
/*  Initial Credit Rule: Credit recurring charge interval that */
/*   Begins prior to end of current interval */
/*   Ends after subscription ends */
/*   Has non-empty intersection with subscription */
/*   If not prorating, don't return a credit for intervals that begin prior to the end of the subscription  */
/*  Charge is generated for the originating account in effect at the end of the */
/*  recurring charge interval. */
  AND
  rci.dt_start < tmp.b_dt_end
  AND
  rci.dt_end > tmp.s_dt_end1
  AND
  rci.dt_end >= tmp.s_dt_start AND rci.dt_start <= tmp.s_dt_end1
  AND
  rci.dt_end BETWEEN tmp.p_vt_start AND tmp.p_vt_end
  AND
  rci.dt_end BETWEEN tmp.o_vt_start AND tmp.o_vt_end
  AND 
  (tmp.b_prorate_on_deactivate='Y' or rci.dt_start > tmp.s_dt_end1)
/* ------- Begin UDRC Stuff */
/*  Valid time interval for UDRC value intersects the recurring charge interval  */
/*  (IS THIS WHAT WE WANT???) */
  AND rci.dt_end >= tmp.v_vt_start AND rci.dt_start <= tmp.v_vt_end
/* ------- End UDRC Stuff */
/*  End Advance Charge Rule */
/*  Advance Charge Rule: Recurring charge interval  */
/*   Begins prior to the end of the billing interval that contains the subscription start. */
/*  N.B. The billing interval containing the subscription start (or the date of originator change) is the */
/*  interval in which the initial charge is billed. */
/*  Charge was billed using payment history version that was (transaction time) */
/*  effective at the time the adapter for the interval in which it was billed was run. */
/*  Charge was billed using originator history version that was (transaction time) */
/*  effective at the time the adapter for the interval in which it was billed was run. */
INNER JOIN t_usage_interval billed ON billed.id_usage_cycle=tmp.b_id_usage_cycle
  AND
  ( 
  tmp.s_dt_start BETWEEN billed.dt_start AND billed.dt_end
  OR
  (tmp.o_vt_start BETWEEN billed.dt_start AND billed.dt_end AND tmp.o_tt_start BETWEEN billed.dt_start AND billed.dt_end)
  )
  AND
  billed.dt_end >= rci.dt_start
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
/*  End Advance Charge Rule */
WHERE
/*  Initial Credit Rule: Process subscriptions that terminate during current  */
/*  interval and began prior to current interval. */
tmp.s_dt_end1 BETWEEN tmp.b_dt_start AND tmp.b_dt_end
  AND tmp.s_dt_start < tmp.b_dt_start
/* ------- Begin UDRC Stuff */
/*  Initial Credit Rule: Credit unit value intervals that end strictly after the subscription end. */
/*  Note that it is possible for the unit value to start after the end of the subscription end. */
  AND tmp.s_dt_end < tmp.v_vt_end
/* ------- End UDRC Stuff */
/*  End Initial Credit Rule */
