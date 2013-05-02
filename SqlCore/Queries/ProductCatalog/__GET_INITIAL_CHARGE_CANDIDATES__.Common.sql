
%%INSERT_INTO_CLAUSE%%
SELECT 
  /* __GET_INITIAL_CHARGE_CANDIDATES__ */
  /* Make room in action type for other strings */
	CAST('Initial' AS VARCHAR(32)) as c_RCActionType,
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
	dbo.MTMaxOfTwoDates(rci.dt_start, tmp.s_dt_start) as c_RCIntervalSubscriptionStart,
	dbo.MTMinOfTwoDates(rci.dt_end, case when tmp.b_dt_end < tmp.s_dt_end then null else tmp.s_dt_end end) as c_RCIntervalSubscriptionEnd,
	tmp.b_advance as c_Advance,
	tmp.b_prorate_on_activate as c_ProrateOnSubscription,
  tmp.b_prorate_instantly as c_ProrateInstantly,
	tmp.b_prorate_on_deactivate as c_ProrateOnUnsubscription,
	case tmp.b_fixed_proration_length when 'Y' then tmp.n_proration_length else 0 end as c_ProrationCycleLength,	
  {ts '1970-01-01 00:00:00'} as c_BilledRateDate,
  tmp.p_tt_end candidate_tt_end,
	tmp.o_tt_end candidate_originator_tt_end,
	tmp.b_per_subscription b_per_subscription ,
  tmp.v_value as c_UnitValue,
  tmp.v_vt_start as c_UnitValueStart,
  tmp.v_vt_end as c_UnitValueEnd,
  tmp.n_rating_type as c_RatingType,
	tmp.run_id_event as run_id_event,
	tmp.run_vt_start as run_vt_start
%%INTO_CLAUSE%%
FROM 
/*  Initial Charge Rule: The system ignores retroactive changes to payment when */
/*  giving credits for advance charges. */
%%%TEMP_TABLE_PREFIX%%%tmp_rc_advance_1 tmp
/*  End Advance Charge Rule */
/*  Consider all recurring charge intervals of the appropriate cycle */
INNER JOIN t_pc_interval rci ON rci.id_cycle=tmp.rci_id_cycle
/*  Initial Charge Rule: Recurring charge begins prior to end of current interval */
/*  and has non-zero intersection with subscription */
/*   Charge is billed by payer from history who is (valid time) effective */
/*   at the end of the recurring charge interval. */
/*  Charge is generated for the originating account in effect at the end of the */
/*  recurring charge interval. */
  AND
  rci.dt_start < tmp.b_dt_end
  AND
  rci.dt_end >= tmp.s_dt_start AND rci.dt_start <= tmp.s_dt_end
  AND
  rci.dt_end BETWEEN tmp.p_vt_start AND tmp.p_vt_end
  AND
  rci.dt_end BETWEEN tmp.o_vt_start AND tmp.o_vt_end
/* ------- Begin UDRC Stuff */
/*  Valid time interval for UDRC value intersects the recurring charge interval  */
/*  (IS THIS WHAT WE WANT???) */
  AND rci.dt_end >= tmp.v_vt_start AND rci.dt_start <= tmp.v_vt_end
/* ------- End UDRC Stuff */
/*  End Initial Charge Rule */
WHERE
/*  Initial Charge Rule:  */
/*  1) Process subscriptions that begin during the current interval or for which */
/*  the receiver changed during the interval. */
/*  2) Use version of payment history that is transaction time effective at the time the */
/*  adapter for this interval is run. */
/*  3) Charge is billed using originator history version that was (transaction time) */
/*  effective at the time the adapter for this interval is run. */
tmp.run_vt_start BETWEEN tmp.p_tt_start AND tmp.p_tt_end
AND
tmp.run_vt_start BETWEEN tmp.o_tt_start AND tmp.o_tt_end
AND
(
tmp.s_dt_start BETWEEN tmp.b_dt_start AND tmp.b_dt_end
OR
(tmp.o_vt_start BETWEEN tmp.b_dt_start AND tmp.b_dt_end  AND tmp.o_tt_start BETWEEN tmp.b_dt_start AND tmp.b_dt_end)
)
/* ------- Begin UDRC Stuff */
/*  If prorating on activation, only require that the valid time interval  */
/*  ends after the start of subscription.  Note that we can't assume that the unit value */
/*  interval actually intersects the subscription because that would require using the */
/*  end date of the subscription which amounts to using future information about subs */
/*  (which we have agreed NOT to do). */
  AND (tmp.b_prorate_on_activate = 'N' OR tmp.s_dt_start <= tmp.v_vt_end)
/* ------- End UDRC Stuff */
/*  End Initial Charge Rule */
