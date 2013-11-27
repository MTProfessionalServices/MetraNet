
%%INSERT_INTO_CLAUSE%%
SELECT 
/*  __GET_CORRECTIONS_CANDIDATES_WITH_CHANGES__ */
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
        tmp.candidate_tt_end,
  tmp.c_UnitValue,
  tmp.c_UnitValueStart,
  tmp.c_UnitValueEnd,
  tmp.c_RatingType,
	tmp.run_id_event,
	tmp.run_vt_start,
  COUNT(*) AS NumChanges
%%INTO_CLAUSE%%
FROM %%%TEMP_TABLE_PREFIX%%%tmp_recurring_charge_candidate tmp
/*  Initial Correction Rule */
/*  1) Only select RCI/Unit Value intervals for correction if the current */
/*     version of history has changed the value at any time during the intersection */
/*     of the RCI and Unit Value interval */
/*  TODO: Fix bug, if the new version of history has multiple versions that are different  */
/*  from the one we are correcting */
INNER JOIN t_recur_value rv ON rv.id_prop=tmp.c__PriceableItemInstanceID 
  AND 
  rv.id_sub=tmp.c__SubscriptionID
  AND rv.vt_start <= tmp.c_UnitValueEnd AND tmp.c_UnitValueStart <= rv.vt_end
  AND rv.vt_start <= tmp.c_RCIntervalEnd AND tmp.c_RCIntervalStart <= rv.vt_end
  AND rv.n_value <> tmp.c_UnitValue
  AND rv.tt_end = dbo.MTMaxDate()
/*  End Initial Correction Rule */
GROUP BY
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
        tmp.candidate_tt_end,
  tmp.c_UnitValue,
  tmp.c_UnitValueStart,
  tmp.c_UnitValueEnd,
  tmp.c_RatingType,
	tmp.run_id_event,
	tmp.run_vt_start
