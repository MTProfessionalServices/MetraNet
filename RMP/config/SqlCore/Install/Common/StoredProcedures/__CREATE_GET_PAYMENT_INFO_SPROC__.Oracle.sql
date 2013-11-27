
CREATE or replace PROCEDURE GetPaymentInfo(
p_id_acc int,
p_amount OUT number,
p_due_date OUT date,
p_invoice_num OUT number,
p_invoice_date OUT date,
p_currency OUT nvarchar2,
p_last_payment OUT number,
p_last_payment_date OUT date
)
AS
  v_balance number(22,10):=0;
  v_total_payments number(22,10):=0;
  v_balance_date date;
  v_id_interval number(10) := null;

BEGIN
  /* get the amount from the last invoice */
  BEGIN
      SELECT
        current_balance, dt_end, invoice_currency, invoice_due_date, id_invoice_num, invoice_date
      INTO
        v_balance, v_balance_date, p_currency, p_due_date, p_invoice_num, p_invoice_date
      FROM (
        SELECT
          inv.current_balance, ui.dt_end, inv.invoice_currency, inv.invoice_due_date, inv.id_invoice_num, inv.invoice_date
        FROM t_invoice inv
          INNER JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
        WHERE id_acc = p_id_acc
          AND ui.tx_interval_status = 'H'
        ORDER BY ui.dt_end DESC
      ) foo
      WHERE ROWNUM < 2;
  exception
    WHEN NO_DATA_FOUND THEN BEGIN
      v_balance := 0;
      BEGIN 
        select c_currency into p_currency from t_av_internal where id_acc = p_id_acc;
      exception
        WHEN NO_DATA_FOUND THEN p_currency := null;
      END;
      v_balance_date := to_date('1900-01-01','yyyy-mm-dd');
    END;
  END;
    
  IF (v_balance <> 0) THEN
    BEGIN
      SELECT MIN(ui.id_interval)
        INTO v_id_interval
        FROM t_acc_usage_interval aui
            INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
		WHERE aui.id_acc = p_id_acc
			AND ui.dt_end > v_balance_date;

	  /*using product view table instead of t_pv_Payment is significantly faster on partitioned db
	   getting v_id_interval in a separate statement allows us to take advantage from
	   sequential id_usage_intervals.*/
      SELECT SUM(au.Amount)
        INTO v_total_payments
		FROM t_acc_usage au
			INNER JOIN t_prod_view pv on au.id_view = pv.id_view
		WHERE au.id_acc = p_id_acc
			AND pv.nm_table_name in ('t_pv_Payment')
			AND au.id_usage_interval >= v_id_interval
		GROUP BY au.am_currency;  
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            v_total_payments := 0;
         END;
    END;
  END IF;
  
  BEGIN
      SELECT amount, last_payment_date
        INTO p_last_payment, p_last_payment_date
        FROM (SELECT au.amount, p.c_EventDate AS last_payment_date
                  FROM t_acc_usage au 
                   INNER JOIN t_pv_payment p
                       ON au.id_sess = p.id_sess and au.ID_USAGE_INTERVAL = p.ID_USAGE_INTERVAL
                   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
                 WHERE au.id_acc = p_id_acc
                   AND pv.nm_table_name in ('t_pv_Payment')
              ORDER BY p.c_EventDate DESC) foo
       WHERE ROWNUM < 2;
  EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            p_last_payment := 0;
            p_last_payment_date := TO_DATE ('1900-01-01', 'yyyy-mm-dd');
         END;
  END;

  p_amount := v_balance + v_total_payments;
end;
     