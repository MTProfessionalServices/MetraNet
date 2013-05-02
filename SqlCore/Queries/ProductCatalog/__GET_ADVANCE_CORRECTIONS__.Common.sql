
INSERT INTO %%%TEMP_TABLE_PREFIX%%%tmp_recurring_charges
/*  __GET_ADVANCE_CORRECTIONS__ */
SELECT
tmp.c_RCActionType,
tmp.c__AccountID,
tmp.c__PayingAccount,
tmp.c_BillingIntervalStart, 
tmp.c_BillingIntervalEnd,
tmp.c_NextBillingIntervalStart,
tmp.c_NextBillingIntervalEnd,
tmp.c__PriceableItemInstanceID, 
tmp.c__PriceableItemTemplateID,
tmp.c__ProductOfferingID,
tmp.c_RCIntervalStart, 
tmp.c_RCIntervalEnd, 
tmp.c__SubscriptionID,
tmp.c_SubscriptionStart,
tmp.c_SubscriptionEnd,
tmp.c_RCIntervalSubscriptionStart,
tmp.c_RCIntervalSubscriptionEnd,
tmp.c_Advance,
tmp.c_ProrateOnSubscription,
tmp.c_ProrateInstantly,
tmp.c_ProrateOnUnsubscription,
tmp.c_ProrationCycleLength,
tmp.c_BilledRateDate,
  tmp.c_UnitValue,
  tmp.c_UnitValueStart,
  tmp.c_UnitValueEnd,
	tmp.c_RatingType,
	tmp.run_id_event,
	tmp.run_vt_start
/* ------- End UDRC Stuff */
FROM
%%%TEMP_TABLE_PREFIX%%%tmp_recur_charge_candidate2 tmp
INNER JOIN
(
SELECT
tmp1.c__SubscriptionID,
tmp1.c__PriceableItemInstanceID,
tmp1.c_RCIntervalStart,
tmp1.c_RCIntervalEnd,
tmp1.c_UnitValueStart,
tmp1.c_UnitValueEnd,
min(prevpay.tt_end) min_tt_end
FROM
%%%TEMP_TABLE_PREFIX%%%tmp_recur_charge_candidate2 tmp1
INNER JOIN t_payment_redir_history prevpay ON tmp1.c__AccountID=prevpay.id_payee
/*  Advance Correction Rule: */
/*   Charge is billed by payer from history who is (valid time) effective */
/*   at the end of the recurring charge interval. */
  AND
  tmp1.c_RCIntervalEnd BETWEEN prevpay.vt_start AND prevpay.vt_end
/*  End Advance Correction Rule */
INNER JOIN t_acc_usage_interval prevabinterval ON prevabinterval.id_acc=prevpay.id_payer
INNER JOIN t_usage_interval prevbinterval ON prevabinterval.id_usage_interval=prevbinterval.id_interval
/*  Advance Corrections Rule:  */
/*  1) Process subscriptions that terminate after the start of the current  */
/*  interval and began prior to current interval. */
/*  2) Correct recurring charge interval that begins prior to end of current interval */
  AND 
  tmp1.c_SubscriptionEnd > prevbinterval.dt_start 
  AND 
  tmp1.c_SubscriptionStart < prevbinterval.dt_start
  AND
  tmp1.c_RCIntervalStart < prevbinterval.dt_end
/*  End Advance Corrections Rule */
/*  Advance Corrections Rule:  */
/*  1) Billing interval containing the beginning of the recurring */
/*  charge interval begins after subscription begins and before the subscription ends. */
/*  2) Correction was billed using payment history version that was (transaction time) */
/*  effective at the time the adapter for the interval containing the corresponding charge was run. */
INNER JOIN t_usage_interval prevafterbilled ON prevafterbilled.id_usage_cycle=prevbinterval.id_usage_cycle
  AND 
  tmp1.c_RCIntervalStart BETWEEN prevafterbilled.dt_start AND prevafterbilled.dt_end
  AND
  prevafterbilled.dt_start > tmp1.c_SubscriptionStart
  AND
  prevafterbilled.dt_start <= tmp1.c_SubscriptionEnd
INNER JOIN t_usage_interval prevbilled ON prevbilled.id_usage_cycle=prevbinterval.id_usage_cycle 
INNER JOIN t_billgroup_member bgm ON bgm.id_acc=prevpay.id_payer
INNER JOIN t_billgroup bg ON bg.id_billgroup=bgm.id_billgroup AND bg.id_usage_interval=prevbilled.id_interval
INNER JOIN t_recevent_inst rei ON rei.id_event=tmp1.run_id_event AND rei.id_arg_interval=prevbilled.id_interval AND rei.id_arg_billgroup=bg.id_billgroup
INNER JOIN (
  select
  rer.id_instance,
  max(rer.dt_start) as run_vt_start
  from
  t_recevent_run rer
  group by rer.id_instance
  ) rer ON rer.id_instance=rei.id_instance
  AND
  rer.run_vt_start BETWEEN prevpay.tt_start AND prevpay.tt_end
/*  End Advance Corrections Rule */
WHERE
/* This predicate can't go in the INNER JOIN on SQL Server (KB 819264) */
prevafterbilled.dt_start = dbo.AddSecond(prevbilled.dt_end)
GROUP BY
tmp1.c__SubscriptionID,
tmp1.c__PriceableItemInstanceID,
tmp1.c_RCIntervalStart,
tmp1.c_RCIntervalEnd,
tmp1.c_UnitValueStart,
tmp1.c_UnitValueEnd
) foo ON 
tmp.c__SubscriptionID = foo.c__SubscriptionID
AND
tmp.c__PriceableItemInstanceID = foo.c__PriceableItemInstanceID
AND
tmp.c_RCIntervalStart = foo.c_RCIntervalStart
AND
tmp.c_RCIntervalEnd = foo.c_RCIntervalEnd
AND
tmp.c_UnitValueStart = foo.c_UnitValueStart
AND
tmp.c_UnitValueEnd = foo.c_UnitValueEnd
AND
tmp.candidate_tt_end = foo.min_tt_end

