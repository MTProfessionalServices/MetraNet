
---------------------------------------------------------
-- gets payment information to display in MetraView
---------------------------------------------------------
CREATE PROCEDURE [dbo].[GetPaymentInfo](
@id_acc int,                    -- account
@amount numeric(22,10) OUTPUT,  -- last invoice amount - payments
@due_date datetime OUTPUT,      -- payment due date
@invoice_num int OUTPUT,        -- invoice number
@invoice_date datetime OUTPUT,  -- invoice date
@currency nvarchar(3) OUTPUT,    -- currency for account
@last_payment numeric(22,10) OUTPUT, 
@last_payment_date datetime OUTPUT 
)
AS
BEGIN
DECLARE
  @balance numeric(22,10),
  @total_payments numeric(22,10),
  @balance_date datetime,  -- the date the balance was computed
  @id_interval int  -- the min interval

  -- get the amount from the last invoice
  SELECT TOP 1 
    @balance = inv.current_balance,
    @balance_date = ui.dt_end,
    @currency = inv.invoice_currency,
    @due_date = inv.invoice_due_date,
    @invoice_num = inv.id_invoice_num,
    @invoice_date = inv.invoice_date
  FROM t_invoice inv
    JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
  WHERE id_acc = @id_acc
    AND ui.tx_interval_status = 'H'
  ORDER BY ui.dt_end DESC

  IF @balance IS NULL
    BEGIN
    SET @balance = 0
    SET @currency = (select c_currency from t_av_internal where id_acc = @id_acc)
    SET @balance_date = '1900-01-01'
    END


  -- only calculate total payment if balance is non zero.
  -- otherwise there is no payment due and no need for calculations
  if (@balance != 0) 
  BEGIN
	  -- get the payment's total
		SELECT @id_interval = MIN(ui.id_interval)
		FROM t_acc_usage_interval aui
		   INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
		WHERE aui.id_acc = @id_acc
			AND ui.dt_end > @balance_date

	  -- using product view table instead of t_pv_Payment is significantly faster on partitioned db
	  -- getting @id_interval in a separate statement allows us to take advantage from
	  -- sequential id_usage_intervals.
		SELECT @total_payments = SUM(au.Amount)
		FROM t_acc_usage au
			INNER JOIN t_prod_view pv on au.id_view = pv.id_view
		WHERE au.id_acc = @id_acc
			AND pv.nm_table_name in ('t_pv_Payment')
			AND au.id_usage_interval >= @id_interval
		GROUP BY au.am_currency  
  END

  if @total_payments IS NULL
    BEGIN
     SET @total_payments = 0
    END

  -- get the last payment amount, date
  SELECT TOP 1 
    @last_payment = au.Amount,
    @last_payment_date = p.c_EventDate
  FROM t_acc_usage au
   INNER JOIN t_pv_Payment p on p.id_sess = au.id_sess and au.ID_USAGE_INTERVAL = p.ID_USAGE_INTERVAL
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
  WHERE au.id_acc = @id_acc
	AND pv.nm_table_name in ('t_pv_Payment')
  order by p.c_EventDate desc

  if @last_payment IS NULL
    BEGIN
     SET @last_payment = 0
     SET @last_payment_date = '1900-01-01'
    END
  
  -- calculate the amount to pay as balance from the invoice - total payments.
  -- as payments are stored as a negative number using + here
  SET @amount = @balance + @total_payments
END
     