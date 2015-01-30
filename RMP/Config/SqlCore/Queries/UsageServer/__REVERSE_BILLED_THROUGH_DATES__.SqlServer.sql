UPDATE rw 
SET rw.c_BilledThroughDate = bkp.c_BilledThroughDate
FROM t_recur_window rw
  INNER JOIN t_rec_win_bcp_for_reverse bkp
    ON rw.c_CycleEffectiveDate = bkp.c_CycleEffectiveDate 
    AND rw.c__PriceableItemInstanceID = bkp.c__PriceableItemInstanceID
    AND rw.c__PriceableItemTemplateID = bkp.c__PriceableItemTemplateID
    AND rw.c__ProductOfferingID = bkp.c__ProductOfferingID
    AND rw.c__SubscriptionID = bkp.c__SubscriptionID;