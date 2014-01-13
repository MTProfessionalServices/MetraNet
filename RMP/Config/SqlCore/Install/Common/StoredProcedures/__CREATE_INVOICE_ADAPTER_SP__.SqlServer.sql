
CREATE PROCEDURE MTSP_INSERTINVOICE
@id_billgroup int,
@invoicenumber_storedproc nvarchar(256), --this is the name of the stored procedure used to generate invoice numbers
@is_sample varchar(1),
@dt_now DATETIME,  -- the MetraTech system's date
@id_run int,
@num_invoices int OUTPUT,
@return_code int OUTPUT
AS
SET NOCOUNT ON
BEGIN
DECLARE
@invoice_date datetime,
@cnt int,
@curr_max_id int,
@id_interval_exist int,
@id_billgroup_exist int,
@debug_flag bit,
@SQLError int,
@ErrMsg varchar(200)
-- Initialization
SET @num_invoices = 0
SET @invoice_date = CAST(SUBSTRING(CAST(@dt_now AS CHAR),1,11) AS DATETIME) --datepart
SET @debug_flag = 1 -- yes
--SET @debug_flag = 0 -- no
-- Validate input parameter values
IF @id_billgroup IS NULL
BEGIN
  SET @ErrMsg = 'InsertInvoice: Completed abnormally, id_billgroup is null'
  GOTO FatalError
END
if @invoicenumber_storedproc IS NULL OR RTRIM(@invoicenumber_storedproc) = ''
BEGIN
  SET @ErrMsg = 'InsertInvoice: Completed abnormally, invoicenumber_storedproc is null'
  GOTO FatalError
END
IF @debug_flag = 1
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
    VALUES (@id_run, 'Debug', 'InsertInvoice: Started', getutcdate())
-- If already exists, do not process again
SELECT TOP 1 @id_billgroup_exist = id_billgroup
FROM t_invoice_range
WHERE id_billgroup = @id_billgroup and id_run is NULL
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @id_billgroup_exist IS NOT NULL
BEGIN
  SET @ErrMsg = 'InsertInvoice: Invoice number already exists in the t_invoice_range table, '
    + 'process skipped, process completed successfully at '
    + CONVERT(char, getutcdate(), 109)
  GOTO SkipReturn
END
/*  Does an invoice exist for the accounts in the given @id_billgroup */
SELECT TOP 1 @id_interval_exist = id_interval
FROM t_invoice inv
INNER JOIN t_billgroup_member bgm
  ON bgm.id_acc = inv.id_acc
INNER JOIN t_billgroup bg
  ON bg.id_usage_interval = inv.id_interval AND
     bg.id_billgroup = bgm.id_billgroup
WHERE bgm.id_billgroup = @id_billgroup and
            inv.sample_flag = 'N'
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @id_interval_exist IS NOT NULL
BEGIN
  SET @ErrMsg = 'InsertInvoice: Invoice number already exists in the t_invoice table, '
    + 'process skipped, process completed successfully at '
    + CONVERT(char, getdate(), 109)
  GOTO SkipReturn
END

-- call MTSP_INSERTINVOICE_BALANCES to populate #tmp_acc_amounts, #tmp_prev_balance, #tmp_adjustments

CREATE TABLE #tmp_acc_amounts
  (tmp_seq int IDENTITY,
  namespace nvarchar(40),
  id_interval int,
  id_acc int,
  invoice_currency nvarchar(10),
  payment_ttl_amt numeric(22,10),
  postbill_adj_ttl_amt numeric(22,10),
  ar_adj_ttl_amt numeric(22,10),
  previous_balance numeric(22,10),
  tax_ttl_amt numeric(22,10),
  current_charges numeric(22,10),
  id_payer int,
  id_payer_interval int
  )

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

CREATE TABLE #tmp_prev_balance
 ( id_acc int,
   previous_balance numeric(22,10)
 )

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

CREATE TABLE #tmp_adjustments
 ( id_acc int,
   PrebillAdjAmt numeric(22,10),
   PrebillTaxAdjAmt numeric(22,10),
   PostbillAdjAmt numeric(22,10),
   PostbillTaxAdjAmt numeric(22,10)
 )

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- Create the driver table with all id_accs
CREATE TABLE #tmp_all_accounts
(tmp_seq int IDENTITY,
 id_acc int NOT NULL,
 namespace nvarchar(80) NOT NULL)

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

EXEC MTSP_INSERTINVOICE_BALANCES @id_billgroup, 0, @id_run, @return_code OUTPUT

if @return_code <> 0 GOTO FatalError

-- Obtain the configured invoice strings and store them in a temp table
CREATE TABLE #tmp_invoicenumber
(id_acc int NOT NULL,
 namespace nvarchar(40) NOT NULL,
 invoice_string nvarchar(50) NOT NULL,
 invoice_due_date datetime NOT NULL,
 id_invoice_num int NOT NULL)

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

INSERT INTO #tmp_invoicenumber EXEC @invoicenumber_storedproc @invoice_date
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
-- End of 11/20/2002 add

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF @debug_flag = 1
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
  VALUES (@id_run, 'Debug', 'InsertInvoice: Begin Insert into t_invoice', getutcdate())

-- Save all the invoice data to the t_invoice table
INSERT INTO t_invoice
  (namespace,
  invoice_string,
  id_interval,
  id_acc,
  invoice_amount,
  invoice_date,
  invoice_due_date,
  id_invoice_num,
  invoice_currency,
  payment_ttl_amt,
  postbill_adj_ttl_amt,
  ar_adj_ttl_amt,
  tax_ttl_amt,
  current_balance,
  id_payer,
  id_payer_interval,
  sample_flag,
  balance_forward_date)
SELECT
  #tmp_acc_amounts.namespace,
  tmpin.invoice_string, -- from the stored proc as below
  ui.id_interval, /*@id_interval,*/
  #tmp_acc_amounts.id_acc,
  current_charges
    + ISNULL(#tmp_adjustments.PrebillAdjAmt,0)
    + tax_ttl_amt
    + ISNULL(#tmp_adjustments.PrebillTaxAdjAmt,0.0),  -- invoice_amount = current_charges + prebill adjustments + taxes + prebill tax adjustments,
  @invoice_date invoice_date,
  tmpin.invoice_due_date, -- from the stored proc as @invoice_date+@invoice_due_date_offset   invoice_due_date,
  tmpin.id_invoice_num, -- from the stored proc as tmp_seq + @invoice_number - 1,
  invoice_currency,
  payment_ttl_amt, -- payment_ttl_amt
 ISNULL(#tmp_adjustments.PostbillAdjAmt, 0.0) + ISNULL(#tmp_adjustments.PostbillTaxAdjAmt, 0.0), -- postbill_adj_ttl_amt
  ar_adj_ttl_amt, -- ar_adj_ttl_amt
  tax_ttl_amt + ISNULL(#tmp_adjustments.PrebillTaxAdjAmt,0.0), -- tax_ttl_amt
  current_charges + tax_ttl_amt + ar_adj_ttl_amt
	  + ISNULL(#tmp_adjustments.PostbillAdjAmt, 0.0)
    + ISNULL(#tmp_adjustments.PostbillTaxAdjAmt,0.0)
    + payment_ttl_amt
	  + ISNULL(#tmp_prev_balance.previous_balance, 0.0)
    + ISNULL(#tmp_adjustments.PrebillAdjAmt, 0.0)
    + ISNULL(#tmp_adjustments.PrebillTaxAdjAmt,0.0), -- current_balance
  id_payer, -- id_payer
  CASE WHEN #tmp_acc_amounts.id_payer_interval IS NULL
           THEN (SELECT id_usage_interval
                     FROM t_billgroup
	         WHERE id_billgroup = @id_billgroup)/*@id_interval*/
           ELSE #tmp_acc_amounts.id_payer_interval
  END, -- id_payer_interval
  @is_sample sample_flag,
  ui.dt_end -- balance_forward_date
FROM #tmp_acc_amounts
INNER JOIN #tmp_invoicenumber tmpin ON tmpin.id_acc = #tmp_acc_amounts.id_acc
LEFT OUTER JOIN #tmp_prev_balance ON #tmp_prev_balance.id_acc = #tmp_acc_amounts.id_acc
LEFT OUTER JOIN #tmp_adjustments ON #tmp_adjustments.id_acc = #tmp_acc_amounts.id_acc
INNER JOIN t_usage_interval ui ON ui.id_interval IN (SELECT id_usage_interval
			                                               FROM t_billgroup
			                                               WHERE id_billgroup = @id_billgroup)/*= @id_interval*/
INNER JOIN t_av_internal avi ON avi.id_acc = #tmp_acc_amounts.id_acc

SET @num_invoices = @@ROWCOUNT

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- Store the invoice range data to the t_invoice_range table
SELECT @cnt = MAX(tmp_seq)
FROM #tmp_acc_amounts
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF @cnt IS NOT NULL
BEGIN
  --insert info about the current run into the t_invoice_range table
  INSERT INTO t_invoice_range (id_interval, id_billgroup, namespace, id_invoice_num_first, id_invoice_num_last)
  SELECT i.id_interval, bm.id_billgroup, i.namespace, ISNULL(min(id_invoice_num),0), ISNULL(max(id_invoice_num),0)
  FROM t_invoice i
	INNER JOIN t_billgroup_member bm on bm.id_acc = i.id_acc
	INNER JOIN t_billgroup b on b.id_billgroup = bm.id_billgroup
		and i.id_interval = b.id_usage_interval
  WHERE bm.id_billgroup = @id_billgroup
  GROUP BY i.id_interval, bm.id_billgroup, i.namespace

  --update the id_invoice_num_last in the t_invoice_namespace table
  UPDATE t_invoice_namespace
  SET t_invoice_namespace.id_invoice_num_last =
	(	SELECT  CASE WHEN ISNULL(max(t_invoice.id_invoice_num),0) > t_invoice_namespace.id_invoice_num_last THEN ISNULL(max(t_invoice.id_invoice_num),0)
				ELSE t_invoice_namespace.id_invoice_num_last
				END
		FROM t_invoice
		INNER JOIN t_billgroup_member on t_billgroup_member.id_acc = t_invoice.id_acc
		INNER JOIN t_billgroup on t_billgroup.id_billgroup = t_billgroup_member.id_billgroup
  		WHERE t_invoice_namespace.namespace = t_invoice.namespace 
  		AND t_invoice.id_interval = t_billgroup.id_usage_interval
  		AND t_billgroup.id_billgroup = @id_billgroup)
  SELECT @SQLError = @@ERROR
  IF @SQLError <> 0 GOTO FatalError
END
ELSE  SET @cnt = 0

DROP TABLE #tmp_acc_amounts
DROP TABLE #tmp_prev_balance
DROP TABLE #tmp_invoicenumber
DROP TABLE #tmp_adjustments
DROP TABLE #tmp_all_accounts


IF @debug_flag = 1
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
   VALUES (@id_run, 'Debug', 'InsertInvoice: Completed successfully', getutcdate())

SET @return_code = 0
RETURN 0

SkipReturn:
  IF @ErrMsg IS NULL
    SET @ErrMsg = 'InsertInvoice: Process skipped'
  IF @debug_flag = 1
    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate())
  SET @return_code = 0
  RETURN 0

FatalError:
  IF @ErrMsg IS NULL
    SET @ErrMsg = 'InsertInvoice: Adapter stored procedure failed'
  IF @debug_flag = 1
    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate())
  SET @return_code = -1
  RETURN -1

END

