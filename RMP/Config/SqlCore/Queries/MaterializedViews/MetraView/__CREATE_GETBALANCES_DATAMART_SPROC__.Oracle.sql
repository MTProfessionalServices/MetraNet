
	/*  returns all balances for account as of end of interval */
/*  return codes: */
/*  O = OK */
/*  1 = currency mismatch */
CREATE or replace PROCEDURE GetBalances_Datamart( 
p_id_acc int,
p_id_interval int,
p_previous_balance OUT number,
p_balance_forward OUT number,
p_current_balance OUT number,
p_currency OUT nvarchar2,
p_estimation_code OUT int, /* 0 = NONE: no estimate, all balances taken from t_invoice */
                             /* 1 = CURRENT_BALANCE: balance_forward and current_balance estimated, p_previous_balance taken from t_invoice */
                             /* 2 = PREVIOUS_BALANCE: all balances estimated  */
p_return_code OUT int
)
AS
  v_tmp_balance  number(22,10):=0;
  v_balance_date date;
  v_unbilled_prior_charges number(22,10); /* unbilled charges from interval after invoice and before this one */
  v_previous_charges number(22,10);       /* payments, adjsutments for this interval */
  v_current_charges number(22,10);        /* current charges for this interval */
  v_interval_start date;
  v_tmp_amount number(22,10);
  v_tmp_currency nvarchar2(3);

BEGIN

  p_return_code := 0;
  /* step1: check for existing t_invoice, and use that one if exists */

  for i in (
  SELECT  current_balance,
          current_balance - invoice_amount - tax_ttl_amt balance_forward,
          p_balance_forward - payment_ttl_amt - postbill_adj_ttl_amt - ar_adj_ttl_amt previous_balance,
          invoice_currency currency
  FROM t_invoice
  WHERE id_acc = p_id_acc
  AND id_interval = p_id_interval) loop

    p_current_balance  := i.current_balance;
    p_balance_forward  := i.balance_forward;
    p_previous_balance := i.previous_balance;
    p_currency         := i.currency;

  end loop;


  IF p_current_balance IS NOT NULL then
    p_estimation_code := 0 ;
    RETURN; /* done */
  END IF;

  /* step2: get balance (as of v_interval_start) from previous invoice */
  /* set v_interval_start = (select dt_start from t_usage_interval where id_interval = p_id_interval) */
  /* AR: Bug fix for 10238, when billing cycle is changed. */

  for i in (
  select CASE WHEN aui.dt_effective IS NULL THEN
		 ui.dt_start
	     ELSE dbo.addsecond(aui.dt_effective)
	     END  interval_start
    from t_acc_usage_interval aui
	inner join t_usage_interval ui on aui.id_usage_interval = ui.id_interval
	where aui.id_acc = p_id_acc
	AND ui.id_interval = p_id_interval) loop
        v_interval_start := i.interval_start ;
    end loop;
  GetLastBalance (p_id_acc, v_interval_start, p_previous_balance , v_balance_date , p_currency );
  /* step3: calc v_unbilled_prior_charges */

  v_unbilled_prior_charges := 0;
  /* add unbilled payments, and ar adjustments */

  FOR I IN (
  SELECT SUM(au.TotalAmount) tmp_amount,
         au.am_currency tmp_currency
  FROM t_mv_payer_interval au
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
   INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval
   INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')
    AND au.id_acc = p_id_acc
    AND ui.dt_end > v_balance_date
    AND ui.dt_start < v_interval_start
  GROUP BY au.am_currency) loop

      v_tmp_amount   := i.tmp_amount ;
      v_tmp_currency := i.tmp_currency ;

      IF v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
      END IF;

  END LOOP;

  
  v_tmp_amount := nvl(v_tmp_amount, 0);
  v_unbilled_prior_charges := nvl(v_unbilled_prior_charges,0) + nvl(v_tmp_amount,0);
  v_tmp_amount := 0.0;
  /* add unbilled current charges */
  for i in (
  SELECT SUM(nvl(au.TotalAmount, 0.0)) + SUM(nvl(au.TotalTax,0.0)) - SUM(nvl(au.TotalImpliedTax,0.0)) - SUM(nvl(au.TotalInformationalTax,0.0)) 
     + SUM(nvl(au.TotalImplInfTax,0.0)) tmp_amount  ,
     au.am_currency  tmp_currency
  FROM t_mv_payer_interval au
    inner join t_view_hierarchy vh on au.id_view = vh.id_view
    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
    INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval
    INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
  WHERE
    vh.id_view = vh.id_view_parent
    AND au.id_acc = p_id_acc
    /* AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null)) */
    AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
    AND ui.dt_end > v_balance_date
    AND ui.dt_start < v_interval_start
  GROUP BY au.am_currency )loop

      v_tmp_amount   := i.tmp_amount;
      v_tmp_currency := i.tmp_currency;

      IF v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
      END IF;

  end loop;

  v_tmp_amount := nvl(v_tmp_amount, 0);
  v_unbilled_prior_charges := nvl(v_unbilled_prior_charges,0) + nvl(v_tmp_amount,0);

  /* add unbilled pre-bill and post-bill adjustments */
  for i in (SELECT SUM(nvl(PrebillAdjAmt, 0.0)) +
                   SUM(nvl(PostbillAdjAmt, 0.0)) +
                   SUM(nvl(PrebillTaxAdjAmt, 0.0)) +
                   SUM(nvl(PostbillTaxAdjAmt, 0.0)) tmp_balance
     FROM vw_adjustment_summary_datamart
     WHERE id_acc = p_id_acc
     AND dt_end > v_balance_date
     AND dt_start < v_interval_start) loop
       v_tmp_balance  := i.tmp_balance;
   end loop;

  v_unbilled_prior_charges := v_unbilled_prior_charges + nvl(v_tmp_balance, 0);


  /* step4: add v_unbilled_prior_charges to p_previous_balance if any found */
  IF v_unbilled_prior_charges <> 0 then
    p_estimation_code  := 2;
    p_previous_balance := nvl(p_previous_balance,0) + nvl(v_unbilled_prior_charges,0);
  ELSE
    p_estimation_code := 1;
  end if;

  /* step5: get previous charges */
  for i in(
  SELECT
     SUM(au.TotalAmount) previous_charges,
     au.am_currency      tmp_currency
  FROM t_mv_payer_interval au
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')
  AND au.id_acc = p_id_acc
  AND au.id_usage_interval = p_id_interval
  GROUP BY au.am_currency) loop
      v_previous_charges := i.previous_charges;
      v_tmp_currency     := i.tmp_currency;
      IF v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
      END if;
  end loop;

  IF v_previous_charges IS NULL then
    v_previous_charges := 0;
  end if;

  /* add post-bill adjustments */
  v_tmp_balance := 0;
  for i in (SELECT SUM(nvl(PostbillAdjAmt, 0.0)) +
                   SUM(nvl(PostbillTaxAdjAmt, 0.0)) tmp_balance FROM vw_adjustment_summary_datamart
     WHERE id_acc = p_id_acc AND id_usage_interval = p_id_interval) loop
    v_tmp_balance := i.tmp_balance;
  end loop;
  v_previous_charges := v_previous_charges + nvl(v_tmp_balance, 0);


  /* step6: get current charges */
  for i in (
  SELECT
    SUM(nvl(au.TotalAmount, 0.0)) + SUM(nvl(au.TotalTax,0.0)) - SUM((au.TotalImpliedTax,0.0)) - SUM((au.TotalInformationalTax,0.0)) + SUM((au.TotalImplInfTax,0.0)) +
    SUM(nvl(au.PrebillAdjAmt, 0.0)) +
    SUM(nvl(au.PrebillTotalTaxAdjAmt, 0.0)) current_charges,
    au.am_currency  tmp_currency
  FROM t_mv_payer_interval au
    inner join t_view_hierarchy vh on au.id_view = vh.id_view
    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
  WHERE
    vh.id_view = vh.id_view_parent
  AND au.id_acc = p_id_acc
  /*   AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null)) */
  AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
  AND au.id_usage_interval = p_id_interval
  GROUP BY au.am_currency) loop

      v_current_charges := i.current_charges;
      v_tmp_currency    := i.tmp_currency;

      IF v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
      END if;

  end loop;

  IF v_current_charges IS NULL then
    v_current_charges := 0;
  end if;

  p_balance_forward := p_previous_balance + v_previous_charges;
  p_current_balance := p_balance_forward  + v_current_charges;
END;
	