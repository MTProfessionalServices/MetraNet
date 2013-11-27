
/* %%INSERT_INTO_CLAUSE2%% Added this hack since we need to just add this in insert_simple_discount_1 but code is same for both the queries*/
%%INSERT_INTO_CLAUSE%%
/*  Obtain the product interval dates and store in tmp_discount_2 */
SELECT 
  di.id_interval,
  tmp_1.id_acc,
  tmp_1.id_payer,
  tmp_1.id_pi_instance,
  tmp_1.id_pi_template,
  tmp_1.id_po,
  tmp_1.dt_bill_start,
  tmp_1.dt_bill_end,
  tmp_1.dt_sub_start,
  tmp_1.dt_sub_end,
  case when tmp_1.dt_sub_start is null or di.dt_start > tmp_1.dt_sub_start then di.dt_start else tmp_1.dt_sub_start end dt_effdisc_start,
  case when tmp_1.dt_sub_end is null or di.dt_end < tmp_1.dt_sub_end then di.dt_end else tmp_1.dt_sub_end end dt_effdisc_end,
  di.dt_start dt_disc_start,
  di.dt_end dt_disc_end,
  tmp_1.tt_pay_end
%%INTO_CLAUSE%%
FROM 
  %%%TEMP_TABLE_PREFIX%%%tmp_discount_1 tmp_1
INNER JOIN t_pc_interval di 
  ON di.id_cycle = tmp_1.id_usage_cycle AND
     di.dt_start <= tmp_1.dt_sub_end AND 
	   di.dt_end >= tmp_1.dt_sub_start AND
(case when tmp_1.dt_sub_end is null or di.dt_end < tmp_1.dt_sub_end then di.dt_end else tmp_1.dt_sub_end end) BETWEEN tmp_1.dt_bill_start AND tmp_1.dt_bill_end
AND
      /* only includes payers who where valid time effective at the end discount interval */
(case when tmp_1.dt_sub_end is null or di.dt_end < tmp_1.dt_sub_end then di.dt_end else tmp_1.dt_sub_end end) BETWEEN tmp_1.vt_pay_start AND tmp_1.vt_pay_end
WHERE 
  /* only include the transaction time history that was in effect at the end of the billing interval */
  /* NOTE: because of this retroactive payment changes will be ignored */
  tmp_1.dt_bill_end BETWEEN tmp_1.tt_pay_start AND tmp_1.tt_pay_end
