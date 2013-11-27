
INSERT INTO %%%TEMP_TABLE_PREFIX%%%tmp_discount_4 (id_interval, id_group, id_acc, id_pi_instance, amount)
/*  inserts rounded proportional distribution into tmp_discount_4 */
SELECT 
  tmp_3.id_interval,
  tmp_3.id_group,
  tmp_3.id_acc,
  tmp_3.id_pi_instance,
  ROUND(tmp_3.proportion * rated_discount.c_groupdiscountamount, 2) amount
FROM   %%%TEMP_TABLE_PREFIX%%%tmp_discount_3 tmp_3
INNER JOIN t_pv_groupdiscount_temp rated_discount ON 
  rated_discount.c_GroupDiscountIntervalID = tmp_3.id_interval AND
  rated_discount.c_GroupSubscriptionID = tmp_3.id_group
INNER JOIN t_acc_usage au ON
  au.id_sess=rated_discount.id_sess AND
  au.id_usage_interval=rated_discount.id_usage_interval AND
  au.id_pi_instance = tmp_3.id_pi_instance 

