
%%INSERT_INTO_CLAUSE%%
/*  inserts any adjustments to correct rounding errors for each gsub into tmp_discount_5 */
/* Ignore this: %%INSERT_INTO_CLAUSE2%% */
SELECT
  singlemember.id_interval,
  singlemember.id_group,
  singlemember.id_acc,
  singlemember.id_pi_instance,
  rated_discount.c_GroupDiscountAmount - actual.amount adjustment
%%INTO_CLAUSE%%
FROM (
  /* sums up the shares of the discount after being distributed */
  SELECT  
    tmp_4.id_interval,
    tmp_4.id_group,
    tmp_4.id_pi_instance,
	  SUM(tmp_4.amount) amount
  FROM   %%%TEMP_TABLE_PREFIX%%%tmp_discount_4 tmp_4
  INNER JOIN t_pv_groupdiscount_temp rated_discount ON 
    rated_discount.c_GroupDiscountIntervalID = tmp_4.id_interval AND
    rated_discount.c_GroupSubscriptionID = tmp_4.id_group
  INNER JOIN t_acc_usage au ON
    au.id_sess = rated_discount.id_sess AND
    au.id_usage_interval = rated_discount.id_usage_interval AND
    au.id_pi_instance = tmp_4.id_pi_instance
  GROUP BY 
    tmp_4.id_interval,
    tmp_4.id_group,
    tmp_4.id_pi_instance
) actual
/*  gets the expected total group discount amount */
INNER JOIN t_pv_groupdiscount_temp rated_discount ON 
  rated_discount.c_GroupDiscountIntervalID = actual.id_interval AND
  rated_discount.c_GroupSubscriptionID = actual.id_group
INNER JOIN t_acc_usage au ON
  au.id_sess = rated_discount.id_sess AND
  au.id_usage_interval = rated_discount.id_usage_interval AND
  au.id_pi_instance = actual.id_pi_instance
INNER JOIN (
  /* picks one account for each group to get the adjustment */
  SELECT 
    id_interval,
    id_group,
    id_pi_instance,
	  MIN(id_acc) id_acc
  FROM   %%%TEMP_TABLE_PREFIX%%%tmp_discount_4 tmp_4 
  GROUP BY 
    id_interval,
    id_group,
    id_pi_instance
) singlemember ON 
  singlemember.id_interval = actual.id_interval AND
  singlemember.id_group = actual.id_group AND
  singlemember.id_pi_instance = actual.id_pi_instance
WHERE ABS(rated_discount.c_groupdiscountamount - actual.amount) > 0   /* only if there is a rounding error */
