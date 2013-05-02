
---------------------------------------------------------
-- returns all balances for account as of end of interval
-- return codes:
-- O = OK
-- 1 = currency mismatch
---------------------------------------------------------
CREATE PROCEDURE GetBalances(
@id_acc int,
@id_interval int,
@previous_balance numeric(22,10) OUTPUT,
@balance_forward numeric(22,10) OUTPUT,
@current_balance numeric(22,10) OUTPUT,
@currency nvarchar(3) OUTPUT,
@estimation_code int OUTPUT, -- 0 = NONE: no estimate, all balances taken from t_invoice
                             -- 1 = CURRENT_BALANCE: balance_forward and current_balance estimated, @previous_balance taken from t_invoice
                             -- 2 = PREVIOUS_BALANCE: all balances estimated
@return_code int OUTPUT
)
AS
BEGIN
DECLARE
  @balance_date datetime,
  @unbilled_prior_charges numeric(22,10), -- unbilled charges from interval after invoice and before this one
  @previous_charges numeric(22,10),       -- payments, adjsutments for this interval
  @current_charges numeric(22,10),        -- current charges for this interval
  @interval_start datetime,
  @tmp_amount numeric(22,10),
  @tmp_currency nvarchar(3)

  SET @return_code = 0

  -- step1: check for existing t_invoice, and use that one if exists
  SELECT @current_balance = current_balance,
    @balance_forward = current_balance - invoice_amount - tax_ttl_amt,
    @previous_balance = @balance_forward - payment_ttl_amt - postbill_adj_ttl_amt - ar_adj_ttl_amt,
    @currency = invoice_currency
  FROM t_invoice
  WHERE id_acc = @id_acc
  AND id_interval = @id_interval

  IF NOT @current_balance IS NULL
    BEGIN
    SET @estimation_code = 0
    RETURN --done
    END

  -- step2: get balance (as of @interval_start) from previous invoice
  --set @interval_start = (select dt_start from t_usage_interval where id_interval = @id_interval)

  -- AR: Bug fix for 10238, when billing cycle is changed.

  select @interval_start =
	CASE WHEN aui.dt_effective IS NULL THEN
		ui.dt_start
	     ELSE dateadd(s, 1, aui.dt_effective)
	END
  from t_acc_usage_interval aui
	inner join t_usage_interval ui on aui.id_usage_interval = ui.id_interval
	where aui.id_acc = @id_acc
	AND ui.id_interval = @id_interval

  exec GetLastBalance @id_acc, @interval_start, @previous_balance output, @balance_date output, @currency output

  -- step3: calc @unbilled_prior_charges
  set @unbilled_prior_charges = 0

  -- add unbilled payments, and ar adjustments
  SELECT @tmp_amount = SUM(au.Amount),
    @tmp_currency = au.am_currency
  FROM t_acc_usage au
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
   INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval
   INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')
    AND au.id_acc = @id_acc
    AND ui.dt_end > @balance_date
    AND ui.dt_start < @interval_start
  GROUP BY au.am_currency

  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)
  BEGIN
    SET @return_code = 1 -- currency mismatch
    RETURN 1
  END

  SET @tmp_amount = isnull(@tmp_amount, 0)
  SET @unbilled_prior_charges = @unbilled_prior_charges + @tmp_amount

  SET @tmp_amount = 0.0

  -- add unbilled current charges
  SELECT @tmp_amount = SUM(isnull(au.Amount, 0.0)) +
                       SUM(isnull(au.Tax_Federal,0.0)) +
                       SUM(isnull(au.Tax_State,0.0)) +
                       SUM(isnull(au.Tax_County,0.0)) +
                       SUM(isnull(au.Tax_Local,0.0)) +
                       SUM(isnull(au.Tax_Other,0.0)),
    @tmp_currency = au.am_currency
  FROM t_acc_usage au
    inner join t_view_hierarchy vh on au.id_view = vh.id_view
    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
    INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval
    INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
  WHERE
    vh.id_view = vh.id_view_parent
    AND au.id_acc = @id_acc
    AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))
    AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
    AND ui.dt_end > @balance_date
    AND ui.dt_start < @interval_start
  GROUP BY au.am_currency

  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)
  BEGIN
    SET @return_code = 1 -- currency mismatch
    RETURN 1
  END

  SET @tmp_amount = isnull(@tmp_amount, 0)
  SET @unbilled_prior_charges = @unbilled_prior_charges + @tmp_amount

  -- add unbilled pre-bill and post-bill adjustments
  SET @unbilled_prior_charges = @unbilled_prior_charges + isnull(
    (SELECT SUM(isnull(PrebillAdjAmt, 0.0)) +
            SUM(isnull(PostbillAdjAmt, 0.0)) +
            SUM(isnull(PrebillTaxAdjAmt, 0.0)) +
            SUM(isnull(PostbillTaxAdjAmt, 0.0))
     FROM vw_adjustment_summary
     WHERE id_acc = @id_acc
     AND dt_end > @balance_date
     AND dt_start < @interval_start), 0)


  -- step4: add @unbilled_prior_charges to @previous_balance if any found
  IF @unbilled_prior_charges <> 0
    BEGIN
    SET @estimation_code = 2
    SET @previous_balance = @previous_balance + @unbilled_prior_charges
    END
  ELSE
    SET @estimation_code = 1

  -- step5: get previous charges
  SELECT
    @previous_charges = SUM(au.Amount),
    @tmp_currency = au.am_currency
  FROM t_acc_usage au
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')
  AND au.id_acc = @id_acc
  AND au.id_usage_interval = @id_interval
  GROUP BY au.am_currency

  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)
  BEGIN
    SET @return_code = 1 -- currency mismatch
    RETURN 1
  END

  IF @previous_charges IS NULL
    SET @previous_charges = 0

  -- add post-bill adjustments
  SET @previous_charges = @previous_charges + isnull(
    (SELECT SUM(isnull(PostbillAdjAmt, 0.0)) +
            SUM(isnull(PostbillTaxAdjAmt, 0.0)) FROM vw_adjustment_summary
     WHERE id_acc = @id_acc AND id_usage_interval = @id_interval), 0)


  -- step6: get current charges
  SELECT
   @current_charges = SUM(isnull(au.Amount, 0.0)) +
                      SUM(isnull(au.Tax_Federal,0.0)) +
                      SUM(isnull(au.Tax_State,0.0)) +
                      SUM(isnull(au.Tax_County,0.0)) +
                      SUM(isnull(au.Tax_Local,0.0)) +
                      SUM(isnull(au.Tax_Other,0.0)),
   @tmp_currency = au.am_currency
  FROM t_acc_usage au
    inner join t_view_hierarchy vh on au.id_view = vh.id_view
    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
  WHERE
    vh.id_view = vh.id_view_parent
  AND au.id_acc = @id_acc
  AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))
  AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
  AND au.id_usage_interval = @id_interval
  GROUP BY au.am_currency

  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)
  BEGIN
    SET @return_code = 1 -- currency mismatch
    RETURN 1
  END

  IF @current_charges IS NULL
    SET @current_charges = 0

  -- add pre-bill adjustments
  SET @current_charges = @current_charges + isnull(
    (SELECT SUM(isnull(PrebillAdjAmt, 0.0) +
                isnull(PrebillTaxAdjAmt, 0.0)) FROM vw_adjustment_summary
     WHERE id_acc = @id_acc AND id_usage_interval = @id_interval), 0)

  SET @balance_forward = @previous_balance + @previous_charges
  SET @current_balance = @balance_forward + @current_charges
END
     
