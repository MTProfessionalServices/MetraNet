
%%INSERT_INTO_CLAUSE%%
SELECT 
/*  __GET_ADVANCE_CHARGE_CANDIDATES__ */
	'Advance' as c_RCActionType,
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
  /* ESR-2969 */
  /* DB:When we change bill cycle with a BCR and/or EBCR charge, the last bill interval on the old cycle */ 
  /* needs to prorate any advance charges by taking the t_usage_interval.dt_effective into consideration. */
  /* We piggyback on existing proration logic for SubscriptionStart which means that we only get the correct */
  /* behavior if the RC is marked as ProrateOnSubscription.  A more complete fix will require changes to service */
  /* defs and pipelines to properly handle this proration scenario independently. */
 	CASE WHEN recinstance.tx_cycle_mode <> 'Fixed' AND nb_dt_start <> nb_dt_start_corrected 
       THEN dbo.MTMaxOfTwoDates(dbo.AddSecond(nb_dt_start_corrected), rci.dt_start)
       ELSE rci.dt_start END as c_RCIntervalSubscriptionStart,
	rci.dt_end as c_RCIntervalSubscriptionEnd,
	tmp.b_advance as c_Advance,
	tmp.b_prorate_on_activate as c_ProrateOnSubscription,
  tmp.b_prorate_instantly as c_ProrateInstantly,
	tmp.b_prorate_on_deactivate as c_ProrateOnUnsubscription,
	case tmp.b_fixed_proration_length when 'Y' then tmp.n_proration_length else 0 end as c_ProrationCycleLength,
	{ts '1970-01-01 00:00:00'} as c_BilledRateDate,
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
/*  Consider all recurring charge intervals of the appropriate cycle */
INNER JOIN t_pc_interval rci ON rci.id_cycle=tmp.rci_id_cycle
/* ESR-2969 added join to get tx_cycle_mode */
INNER JOIN t_recur recinstance ON tmp.id_pi_instance=recinstance.id_prop
/*  Advance Charge Rules:  */
/*   Recurring charge begins in the next interval */
/*   Charge is billed by payer from history who is (valid time) effective */
/*   at the end of the recurring charge interval. */
/*  Charge is generated for the originating account in effect at the end of the */
/*  recurring charge interval. */
  AND
/* ESR-2969 */
/* DB: Really subtle logic to properly handle bill cycle changes; unfortuntely fixed cycle and BCR */
/* behave differently here */  
  rci.dt_start BETWEEN CASE WHEN recinstance.tx_cycle_mode='Fixed' THEN tmp.nb_dt_start_corrected ELSE tmp.nb_dt_start END AND tmp.nb_dt_end
  AND
  rci.dt_end BETWEEN tmp.p_vt_start AND tmp.p_vt_end
  AND
  rci.dt_end BETWEEN tmp.o_vt_start AND tmp.o_vt_end
/* ------- Begin UDRC Stuff */
/*  Valid time interval for UDRC value intersects the recurring charge interval  */
/*  (IS THIS WHAT WE WANT???) */
  AND rci.dt_end >= tmp.v_vt_start AND rci.dt_start <= tmp.v_vt_end
/* ------- End UDRC Stuff */
/*  End Advance Charge Rule */
WHERE
/*  Advance Charge Rule: */
/*  Charge is billed using payment history version that was (transaction time) */
/*  effective at the time the adapter for the interval in which it was billed was run. */
/*  Charge is billed using originator history version that was (transaction time) */
/*  effective at the time the adapter for the interval in which it was billed was run. */
tmp.run_vt_start BETWEEN tmp.p_tt_start AND tmp.p_tt_end
AND
tmp.run_vt_start BETWEEN tmp.o_tt_start AND tmp.o_tt_end
/*  Advance Charge Rule: Process subscriptions that */
/*   Begin prior to the beginning of the next interval */
/*   End after the beginning of the next interval */
AND tmp.nb_dt_start > tmp.s_dt_start
 AND tmp.nb_dt_start <= tmp.s_dt_end
/* ------- Begin UDRC Stuff */
/*  If prorating on activation, only require that the valid time interval  */
/*  ends after the start of subscription.  Note that we can't assume that the unit value */
/*  interval actually intersects the subscription because that would require using the */
/*  end date of the subscription which amounts to using future information about subs */
/*  (which we have agreed NOT to do). */
  AND (tmp.b_prorate_on_activate = 'N' OR tmp.s_dt_start <= tmp.v_vt_end)
/* ------- End UDRC Stuff */
/*  End Advance Charge Rule */
