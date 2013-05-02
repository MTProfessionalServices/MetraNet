
INSERT INTO %%%TEMP_TABLE_PREFIX%%%tmp_discount_3
/*  inserts each member's proportion of the total group discount into tmp_discount_3 */
SELECT
   tmp_2.id_interval,
   tg.id_group,
   t_acc_usage.id_payee id_acc,
   t_acc_usage.id_pi_instance id_pi_instance,
	 %%PROPORTION_CAST%% proportion
FROM
   %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 tmp_2
   INNER JOIN t_group_sub tg ON tg.id_group = tmp_2.id_acc
   INNER JOIN t_gsubmember tgs ON tg.id_group = tgs.id_group
   INNER JOIN t_sub sub ON sub.id_group = tg.id_group
   INNER JOIN t_acc_usage ON t_acc_usage.id_payee = tgs.id_acc
   INNER JOIN t_pv_groupdiscount_temp rated_discount ON
     rated_discount.c_GroupDiscountIntervalID = tmp_2.id_interval AND
     rated_discount.c_GroupSubscriptionID = tg.id_group
   %%DISTRIBUTION_USAGE_OUTER_JOINS%% 
   %%ADJUSTMENTS_OUTER_JOINS%%
WHERE
   tg.b_proportional = 'Y' AND
   %%ACC_USAGE_FILTER%% AND
   rated_discount.c_groupdiscountamount <> 0  /* we don't need proportions if there is nothing to divide up */
GROUP BY 
   tmp_2.id_interval,
   tg.id_group,
   t_acc_usage.id_payee,
   t_acc_usage.id_pi_instance,
   rated_discount.c_distributioncounter
HAVING
   %%DISTRIBUTION_COUNTER%% <> 0  /* only record non-zero proportions */
