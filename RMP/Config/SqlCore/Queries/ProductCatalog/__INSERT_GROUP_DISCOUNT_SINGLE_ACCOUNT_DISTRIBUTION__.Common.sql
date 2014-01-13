
INSERT INTO %%%TEMP_TABLE_PREFIX%%%tmp_discount_4 (id_interval, id_group, id_acc, id_pi_instance, amount)
/*  inserts single-account distribution into tmp_discount_4 */
SELECT
   rated_discount.c_groupdiscountintervalid AS id_interval,
   rated_discount.c_groupsubscriptionid AS c_GroupSubscriptionID,
   gsub.id_DiscountAccount,  
   au.id_pi_instance,
   rated_discount.c_groupdiscountamount
FROM t_group_sub gsub 
INNER JOIN t_pv_groupdiscount_temp rated_discount ON gsub.id_group = rated_discount.c_groupsubscriptionid 
INNER JOIN t_acc_usage au ON au.id_sess=rated_discount.id_sess AND au.id_usage_interval=rated_discount.id_usage_interval
WHERE 
  gsub.b_proportional = 'N' AND
  rated_discount.c_groupdiscountamount <> 0
