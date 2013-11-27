
INSERT INTO %%%TEMP_TABLE_PREFIX%%%tmp_recurring_charges
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
/*  Initial Correction Rule: */
/*   Charge is billed by payer from history who is (valid time) effective */
/*   at the end of the recurring charge interval. */
  AND
  tmp1.c_RCIntervalEnd BETWEEN prevpay.vt_start AND prevpay.vt_end
/*  End Initial Charge Rule */
INNER JOIN t_acc_usage_interval prevabinterval ON prevabinterval.id_acc=prevpay.id_payer
/*  This is the bill interval in which the correction "might" have been created already. */
INNER JOIN t_usage_interval prevbinterval ON prevabinterval.id_usage_interval=prevbinterval.id_interval
/*  Initial Correction Rule:  */
/*  1) Process subscriptions that began prior to current interval. */
/*  2) Credit recurring charge interval that begins prior to end of current interval and */
/*     ends after the beginning of the interval. */
  AND 
  tmp1.c_SubscriptionStart < prevbinterval.dt_start
  AND
  tmp1.c_RCIntervalStart < prevbinterval.dt_end
/*  End Initial Correction Rule */
/*  Initial Correction Rule:  */
/*  1) Recurring charge interval begins prior to the end of the billing interval that contains the subscription start. */
/*  N.B. The billing interval containing the subscription start is the */
/*  interval in which the initial charge is billed. */
/*  2) Correction would have been using payment history version that was (transaction time) */
/*  effective at the time that the adapter for the interval containing the original charge was run. */
/*  This is the bill interval in which the charge being considered for correction was generated. */
INNER JOIN t_usage_interval prevbilled ON prevbilled.id_usage_cycle=prevbinterval.id_usage_cycle
  AND 
  tmp1.c_SubscriptionStart BETWEEN prevbilled.dt_start AND prevbilled.dt_end
  AND
  prevbilled.dt_end >= c_RCIntervalStart
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
/*  End Initial Correction Rule */
WHERE
/*  Initial Correction Rule: */
/*  1) Recurring charge interval has non empty intersection with subscription interval */
tmp1.c_RCIntervalEnd >= tmp1.c_SubscriptionStart AND tmp1.c_RCIntervalStart <=tmp1.c_SubscriptionEnd
/*  End Initial Correction Rule */
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
