
SELECT  
  %%INFO_LABEL%%
  tmp_2.id_acc AS c__AccountID,
  tmp_2.id_payer AS c__PayingAccount,
  tmp_2.id_pi_instance AS c__PriceableItemInstanceID, 
  tmp_2.id_pi_template AS c__PriceableItemTemplateID,
  tmp_2.id_po as c__ProductOfferingID,
  tmp_2.dt_bill_start AS c_BillingIntervalStart, 
  tmp_2.dt_bill_end AS c_BillingIntervalEnd, 
  tmp_2.dt_disc_start AS c_DiscountIntervalStart, 
  tmp_2.dt_disc_end AS c_DiscountIntervalEnd, 
  CASE WHEN tmp_2.dt_sub_start = {ts '1900-01-01 00:00:00'} /* TO_DATE('1900-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')  */
  THEN NULL ELSE tmp_2.dt_sub_start END AS c_SubscriptionStart,
  CASE WHEN tmp_2.dt_sub_end = {ts '4000-12-31 23:59:59'}   /* TO_DATE('4000-12-31 23:59:59', 'yyyy-mm-dd hh24:mi:ss')  */
  THEN NULL ELSE tmp_2.dt_sub_end END AS c_SubscriptionEnd,
  tmp_2.dt_effdisc_start AS c_DiscountIntervalSubStart,
  tmp_2.dt_effdisc_end AS c_DiscountIntervalSubEnd
	%%COUNTERS%%
FROM	
  %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 tmp_2
/*  only generate discounts for payee's who haven't had discounts */
/*  generated already by a different payer */
INNER JOIN
  (
    SELECT
      tmp_2.id_acc,
      tmp_2.dt_disc_start,
      tmp_2.dt_disc_end,
      MIN(prevpay.tt_end) tt_pay_end
    FROM
      %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 tmp_2
    INNER JOIN t_payment_redir_history prevpay ON tmp_2.id_acc = prevpay.id_payee
      /*  Discount is billed by payer from history who is (valid time) effective */
      /*  at the end of the subscription adjusted discount interval. */
      AND tmp_2.dt_effdisc_end BETWEEN prevpay.vt_start AND prevpay.vt_end
    INNER JOIN t_acc_usage_interval prevabinterval ON prevabinterval.id_acc = prevpay.id_payer
    INNER JOIN t_usage_interval prevbinterval ON prevbinterval.id_interval = prevabinterval.id_usage_interval
      /* Discount is billed using payment history version that was (transaction time) */
      /* effective at the end of the interval in which it was billed. */
      AND prevbinterval.dt_end BETWEEN prevpay.tt_start AND prevpay.tt_end
      /* Subscription adjusted discount interval must end in the billing interval */
      AND tmp_2.dt_effdisc_end BETWEEN prevbinterval.dt_start AND prevbinterval.dt_end
    GROUP BY
      tmp_2.id_acc,
      tmp_2.dt_disc_start,
      tmp_2.dt_disc_end
  ) foo ON foo.id_acc = tmp_2.id_acc AND
           foo.dt_disc_start = tmp_2.dt_disc_start AND
           foo.dt_disc_end = tmp_2.dt_disc_end AND
           foo.tt_pay_end = tmp_2.tt_pay_end
%%OPTIONAL_ACC_USAGE_JOIN%%
%%COUNTER_USAGE_OUTER_JOINS%% 
%%ADJUSTMENTS_OUTER_JOINS%% 
GROUP BY
  tmp_2.id_acc,
  tmp_2.id_payer,
  tmp_2.id_pi_instance, 
  tmp_2.id_pi_template,
  tmp_2.id_po,
  tmp_2.dt_bill_start, 
  tmp_2.dt_bill_end, 
  tmp_2.dt_disc_start, 
  tmp_2.dt_disc_end, 
  tmp_2.dt_sub_start,
  tmp_2.dt_sub_end,
  tmp_2.dt_effdisc_start,
  tmp_2.dt_effdisc_end
