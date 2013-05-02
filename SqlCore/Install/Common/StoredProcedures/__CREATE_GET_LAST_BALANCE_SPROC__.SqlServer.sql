
---------------------------------------------------------
-- gets last calculated balance for an account
-- or latest calculated balance based on a cut-off date
---------------------------------------------------------
CREATE PROCEDURE GetLastBalance(
@id_acc int,                    -- account
@before_date datetime,          -- last balance before this date, can be NULL
@balance numeric(22,10) OUTPUT, -- the balance
@balance_date datetime OUTPUT,  -- the date the balance was computed
@currency nvarchar(3) OUTPUT     -- currency for account
)
AS
BEGIN

  SELECT TOP 1 @balance = inv.current_balance,
    @balance_date = ui.dt_end,
    @currency = inv.invoice_currency
  FROM t_invoice inv
  JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
  WHERE id_acc = @id_acc
    AND (@before_date IS NULL OR ui.dt_end < @before_date)
  ORDER BY ui.dt_end DESC

  IF @balance IS NULL
    BEGIN
    SET @balance = 0
    SET @currency = (select c_currency from t_av_internal where id_acc = @id_acc)
    SET @balance_date = '1900-01-01'
    END
END
     