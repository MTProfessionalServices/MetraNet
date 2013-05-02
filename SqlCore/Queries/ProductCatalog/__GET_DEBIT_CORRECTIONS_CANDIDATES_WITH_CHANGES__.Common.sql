
%%INSERT_INTO_CLAUSE%%
SELECT
/*  __GET_DEBIT_CORRECTIONS_CANDIDATES_WITH_CHANGES__ */
/*  It is easier to make DebitCorrection correct if we use the information */
/*  about the initial corrections and the advance corrections to be generated. */
/*  For any UnitValue in the "current history" whose effective interval intersects */
/*  both the RCI and UnitInterval of a initial or advance correction, we need to */
/*  generate the debit correction. */
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
/*  Debit Correction Rule */
/*  1) Only select RCI/Unit Value intervals for debit correction if the intersection */
/*  of the unit value interval and the RCI of the debit has non-empty intersection of */
/*  the intersection of the unit value interval and RCI of some advance or initial correction */
/*  that we are generating */
INNER JOIN %%%TEMP_TABLE_PREFIX%%%tmp_recurring_charges rv ON rv.c__PriceableItemInstanceID =tmp.c__PriceableItemInstanceID 
  AND 
  rv.c__SubscriptionID=tmp.c__SubscriptionID
  AND rv.c_UnitValueStart <= tmp.c_UnitValueEnd AND tmp.c_UnitValueStart <= rv.c_UnitValueEnd
  AND rv.c_UnitValueStart <= tmp.c_RCIntervalEnd AND tmp.c_UnitValueStart <= rv.c_RCIntervalEnd
  AND rv.c_RCIntervalStart <= tmp.c_UnitValueEnd AND tmp.c_RCIntervalStart <= rv.c_UnitValueEnd
  AND rv.c_RCIntervalStart <= tmp.c_RCIntervalEnd AND tmp.c_RCIntervalStart <= rv.c_RCIntervalEnd
WHERE
rv.c_RCActionType='AdvanceCorrection' OR rv.c_RCActionType='InitialCorrection'
/*  End Debit Correction Rule */
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
