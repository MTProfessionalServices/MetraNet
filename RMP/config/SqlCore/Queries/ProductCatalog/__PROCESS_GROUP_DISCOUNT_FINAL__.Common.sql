
SELECT
   /* this is the final rowset metered to the second pass discount stage */
   tmp_2.id_pi_instance c__PriceableItemInstanceID,
   tmp_2.id_pi_template c__PriceableItemTemplateID,
   tmp_2.id_po c__ProductOfferingID,
   CASE WHEN tmp_2.dt_sub_start = {ts '1900-01-01 00:00:00'} /* TO_DATE('1900-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')  */
   THEN NULL ELSE tmp_2.dt_sub_start END AS c_SubscriptionStart,
   CASE WHEN tmp_2.dt_sub_end = {ts '4000-12-31 23:59:59'}   /* TO_DATE('4000-12-31 23:59:59', 'yyyy-mm-dd hh24:mi:ss')  */
   THEN NULL ELSE tmp_2.dt_sub_end END AS c_SubscriptionEnd,
   tmp_2.dt_disc_start AS c_DiscountIntervalStart, 
   tmp_2.dt_disc_end AS c_DiscountIntervalEnd, 
   tmp_2.dt_effdisc_start AS c_DiscountIntervalSubStart,
   tmp_2.dt_effdisc_end AS c_DiscountIntervalSubEnd,
   '2' c_GroupDiscountPass,
   tmp_2.id_acc c_GroupSubscriptionID,
   gsub.tx_name c_GroupSubscriptionName,
   rated_discount.c_DiscountPercent c_GroupDiscountPercent,
   tmp_4.id_acc c__AccountID,  
   tmp_4.amount c_GroupDiscountAmount
FROM %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 tmp_2
INNER JOIN %%%TEMP_TABLE_PREFIX%%%tmp_discount_4 tmp_4 ON
  tmp_4.id_interval = tmp_2.id_interval AND
  tmp_4.id_group = tmp_2.id_acc AND
  tmp_4.id_pi_instance = tmp_2.c__PriceableItemInstanceID
INNER JOIN t_group_sub gsub ON gsub.id_group = tmp_2.id_acc
INNER JOIN t_pv_groupdiscount_temp rated_discount ON
  rated_discount.c_GroupDiscountIntervalID = tmp_2.id_interval AND
  rated_discount.c_GroupSubscriptionID = tmp_2.id_acc
WHERE
EXISTS (
  SELECT 1
  FROM t_acc_usage au
  WHERE
  au.id_sess=rated_discount.id_sess AND
  au.id_usage_interval=rated_discount.id_usage_interval AND
  au.id_pi_instance=tmp_2.c__PriceableItemInstanceID
)
