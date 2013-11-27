
SELECT
   /* this is the final rowset metered to the second pass discount stage */
   tmp_2.c__PriceableItemInstanceID,
   tmp_2.c__PriceableItemTemplateID,
   tmp_2.c__ProductOfferingID,
   tmp_2.c_SubscriptionStart,
   tmp_2.c_SubscriptionEnd,
   tmp_2.c_DiscountIntervalStart, 
   tmp_2.c_DiscountIntervalEnd, 
   tmp_2.c_DiscountIntervalSubStart,
   tmp_2.c_DiscountIntervalSubEnd,
   '2' c_GroupDiscountPass,
   tmp_2.c_GroupSubscriptionID,
   gsub.tx_name c_GroupSubscriptionName,
   rated_discount.c_DiscountPercent c_GroupDiscountPercent,
   tmp_4.id_acc c__AccountID,  
   tmp_4.amount c_GroupDiscountAmount
FROM tmp_all_disc_desc tmp_2
INNER JOIN %%%TEMP_TABLE_PREFIX%%%tmp_discount_4 tmp_4 ON
  tmp_4.id_interval = tmp_2.c_DiscountIntervalID AND
  tmp_4.id_group = tmp_2.c_GroupSubscriptionID AND
  tmp_4.id_pi_instance = tmp_2.c__PriceableItemInstanceID
INNER JOIN t_group_sub gsub ON gsub.id_group = tmp_2.c_GroupSubscriptionID
INNER JOIN t_pv_groupdiscount_temp rated_discount ON
  rated_discount.c_GroupDiscountIntervalID = tmp_2.c_DiscountIntervalID AND
  rated_discount.c_GroupSubscriptionID = tmp_2.c_GroupSubscriptionID
WHERE
EXISTS (
  SELECT 1
  FROM t_pi_template p
  WHERE
  p.id_template=tmp_2.c__PriceableItemTemplateID
  AND
  p.id_pi=%%ID_PI%%
)
AND EXISTS (
  SELECT 1
  FROM t_acc_usage au
  WHERE
  au.id_sess=rated_discount.id_sess AND
  au.id_usage_interval=rated_discount.id_usage_interval AND
  au.id_pi_instance=tmp_2.c__PriceableItemInstanceID
)
