
LEFT OUTER JOIN (
  SELECT 
    tmp_2.id_interval id_interval,
    tg.id_group id_group
  %%COUNTERS%%
  FROM
    %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 tmp_2
  INNER JOIN t_group_sub tg ON tg.id_group = tmp_2.id_acc 
  INNER JOIN t_gsubmember tgs ON tgs.id_group = tg.id_group
  INNER JOIN t_sub sub ON sub.id_group = tg.id_group
  INNER JOIN t_acc_usage ON t_acc_usage.id_payee = tgs.id_acc
  %%COUNTER_USAGE_OUTER_JOINS%%
  %%ADJUSTMENTS_OUTER_JOINS%%
  WHERE
    /* this should go in the t_acc_usage inner join */
    /* but SQL server has a problem with this */
    %%ACC_USAGE_FILTER%%
  GROUP BY
    /* get totals for each discount interval, for each group subscription */
    tmp_2.id_interval,
    tg.id_group
) counters ON 
  counters.id_interval = tmp_2.id_interval AND
  counters.id_group = tmp_2.id_acc
