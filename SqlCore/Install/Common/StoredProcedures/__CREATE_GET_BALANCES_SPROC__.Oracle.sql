
/*  returns all balances for account as of end of interval */
/*  return codes: */
/*  O = OK */
/*  1 = currency mismatch */
CREATE or replace PROCEDURE GetBalances(
p_id_acc int,
p_id_interval int,
p_previous_balance OUT number ,
p_balance_forward OUT number ,
p_current_balance OUT number ,
p_currency OUT nvarchar2 ,
p_estimation_code OUT int ,  /* 0 = NONE: no estimate, all balances taken from t_invoice */
                             /* 1 = CURRENT_BALANCE: balance_forward and current_balance estimated, p_previous_balance taken from t_invoice */
                             /* 2 = PREVIOUS_BALANCE: all balances estimated  */
p_return_code OUT int
)
AS
  v_temp_bal number(22,10):=0;
  v_balance_date date;
  v_unbilled_prior_charges number(22,10);  /* unbilled charges from interval after invoice and before this one */
  v_previous_charges number(22,10);        /* payments, adjsutments for this interval */
  v_current_charges number(22,10);         /* current charges for this interval */
  v_interval_start date;
  v_tmp_amount number(22,10);
  v_tmp_currency nvarchar2(3);

BEGIN

  p_return_code := 0;

  /* step1: check for existing t_invoice, and use that one if exists */
  for i in ( SELECT
    current_balance current_balance ,
    current_balance - invoice_amount - tax_ttl_amt balance_forward,
    p_balance_forward - payment_ttl_amt - postbill_adj_ttl_amt - ar_adj_ttl_amt previous_balance,
    invoice_currency currency
  FROM t_invoice
  WHERE id_acc = p_id_acc
  AND id_interval = p_id_interval) loop

    p_current_balance := i.current_balance ;
    p_balance_forward := i.balance_forward;
    p_previous_balance := i.previous_balance;
    p_currency := i.currency;

  end loop;

  IF p_current_balance IS NOT NULL THEN
    p_estimation_code := 0 ;
    RETURN; /* done */
  END IF;

  /* step2: get balance (as of v_interval_start) from previous invoice */
  /* set v_interval_start = (select dt_start from t_usage_interval where id_interval = p_id_interval) */
  /* AR: Bug fix for 10238, when billing cycle is changed. */

  for i in (select CASE WHEN aui.dt_effective IS NULL THEN ui.dt_start
                        ELSE dbo.addsecond(aui.dt_effective)
                   END effect_dt
            from t_acc_usage_interval aui
        	inner join t_usage_interval ui on aui.id_usage_interval = ui.id_interval
        	where aui.id_acc = p_id_acc
        	AND ui.id_interval = p_id_interval)
    loop
        v_interval_start := i.effect_dt;
    end loop;

  GetLastBalance (p_id_acc, v_interval_start, p_previous_balance , v_balance_date , p_currency);

  /* step3: calc v_unbilled_prior_charges */
  v_unbilled_prior_charges := 0;

  /* add unbilled payments, and ar adjustments */

  for i in (SELECT SUM(au.Amount) Amount,
     au.am_currency am_currency
  FROM t_acc_usage au
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
   INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval
   INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')
    AND au.id_acc = p_id_acc
    AND ui.dt_end > v_balance_date
    AND ui.dt_start < v_interval_start
  GROUP BY au.am_currency)
  loop
    v_tmp_amount   := i.Amount;
    v_tmp_currency := i.am_currency;
    if v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
    end if;
  end loop;

  v_tmp_amount := nvl(v_tmp_amount, 0);
  v_unbilled_prior_charges := v_unbilled_prior_charges + v_tmp_amount;
  v_tmp_amount := 0.0;

  /* add unbilled current charges */
  for i in
  (SELECT SUM(nvl(au.Amount, 0.0)) +
          SUM(nvl(au.Tax_Federal,0.0)) +
          SUM(nvl(au.Tax_State,0.0)) +
          SUM(nvl(au.Tax_County,0.0)) +
          SUM(nvl(au.Tax_Local,0.0)) +
          SUM(nvl(au.Tax_Other,0.0)) amt,
          au.am_currency curr
  FROM t_acc_usage au
    inner join t_view_hierarchy vh on au.id_view = vh.id_view
    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
    INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval
    INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
  WHERE
    vh.id_view = vh.id_view_parent
    AND au.id_acc = p_id_acc
    AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))
    AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
    AND ui.dt_end > v_balance_date
    AND ui.dt_start < v_interval_start
  GROUP BY au.am_currency)
  loop
      v_tmp_amount   :=   i.amt;
      v_tmp_currency :=   i.curr;
      IF v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
      END if;
  end loop;

  v_tmp_amount := nvl(v_tmp_amount, 0);
  v_unbilled_prior_charges := nvl(v_unbilled_prior_charges,0) + nvl(v_tmp_amount,0);

  /* add unbilled pre-bill and post-bill adjustments */
        SELECT SUM(nvl(PrebillAdjAmt,0.0)) +
               SUM(nvl(PostbillAdjAmt,0.0)) +
               SUM(nvl(PrebillTaxAdjAmt,0.0)) +
               SUM(nvl(PostbillTaxAdjAmt,0.0))
        into v_temp_bal
         FROM vw_adjustment_summary
         WHERE id_acc = p_id_acc
         AND dt_end > v_balance_date
         AND dt_start < v_interval_start;

         v_unbilled_prior_charges := nvl(v_unbilled_prior_charges,0) + nvl(v_temp_bal,0);

  /* step4: add v_unbilled_prior_charges to p_previous_balance if any found */
  IF v_unbilled_prior_charges <> 0 then
    p_estimation_code  := 2;
    p_previous_balance := p_previous_balance + v_unbilled_prior_charges;
  ELSE
    p_estimation_code := 1;
  END IF;

  /* step5: get previous charges */
  for i in (SELECT
     SUM(au.Amount) amt,
     au.am_currency curr
  FROM t_acc_usage au
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')
  AND au.id_acc = p_id_acc
  AND au.id_usage_interval = p_id_interval
  GROUP BY au.am_currency) loop
       v_previous_charges := i.amt;
       v_tmp_currency     := i.curr;
        if v_tmp_currency <> p_currency then
            p_return_code := 1; /* currency mismatch */
            RETURN;
        END if;
   end loop;

  IF v_previous_charges IS NULL then
    v_previous_charges := 0;
  end if;

  /* add post-bill adjustments */
     SELECT SUM(nvl(PostbillAdjAmt,0.0)) +
            SUM(nvl(PostbillTaxAdjAmt,0.0)) into v_temp_bal FROM vw_adjustment_summary
     WHERE id_acc = p_id_acc AND id_usage_interval = p_id_interval;

     v_previous_charges := v_previous_charges + nvl(v_temp_bal,0);


  /* step6: get current charges */
  for i in(
  SELECT
   SUM(nvl(au.Amount, 0.0)) +
   SUM(nvl(au.Tax_Federal, 0.0)) +
   SUM(nvl(au.Tax_State, 0.0)) +
   SUM(nvl(au.Tax_County, 0.0)) +
   SUM(nvl(au.Tax_Local, 0.0)) +
   SUM(nvl(au.Tax_Other, 0.0)) amt,
   au.am_currency curr
  FROM t_acc_usage au
    inner join t_view_hierarchy vh on au.id_view = vh.id_view
    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
  WHERE
    vh.id_view = vh.id_view_parent
  AND au.id_acc = p_id_acc
  AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))
  AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
  AND au.id_usage_interval = p_id_interval
  GROUP BY au.am_currency)
  loop
      v_current_charges :=i.amt;
      v_tmp_currency    := i.curr;
      if v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
      END if;
  end loop;

  IF v_current_charges IS NULL then
    v_current_charges := 0;
  end if;

  /* add pre-bill adjustments */
    SELECT nvl(SUM(PrebillAdjAmt),0) +
           nvl(SUM(PrebillTaxAdjAmt),0) into v_temp_bal FROM vw_adjustment_summary
    WHERE id_acc = p_id_acc AND id_usage_interval = p_id_interval;

    v_current_charges := v_current_charges + nvl(v_temp_bal,0);
    p_balance_forward := p_previous_balance + v_previous_charges;
    p_current_balance := p_balance_forward + v_current_charges;
END;
     