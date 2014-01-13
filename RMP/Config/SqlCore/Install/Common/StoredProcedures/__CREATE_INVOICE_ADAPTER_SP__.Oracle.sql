
CREATE or replace PROCEDURE MTSP_INSERTINVOICE
    (p_id_billgroup int,
    p_invoicenumber_storedproc varchar2, /* this is the name of the stored procedure used to generate invoice numbers */
    p_is_sample varchar2,
    p_dt_now DATE,  /* the MetraTech system's date */
    p_id_run int,
    p_num_invoices OUT int ,
    p_return_code OUT int)
AS
    v_invoice_date date := trunc(p_dt_now);
    v_cnt int;
    v_id_interval_exist int;
    v_id_billgroup_exist int;
    v_debug_flag number(1) := 1 ; -- yes
    v_ErrMsg varchar(200);
    type v_cur is ref cursor;
    v_cur1   v_cur;
    v_tmp_invoicenumber tmp_invoicenumber%ROWTYPE;
    FatalError exception ;
    SkipReturn exception ;
BEGIN

    -- Initialization
    p_num_invoices := 0;

    -- Validate input parameter values
    IF p_id_billgroup IS NULL
    THEN
      v_ErrMsg := 'InsertInvoice: Completed abnormally, id_billgroup is null';
      raise FatalError;
    END IF;
    if p_invoicenumber_storedproc IS NULL OR RTRIM(p_invoicenumber_storedproc) = ''
    then
      v_ErrMsg := 'InsertInvoice: Completed abnormally, invoicenumber_storedproc is null';
      raise FatalError;
    END if;
    IF v_debug_flag = 1 then

      INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
        VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'InsertInvoice: Started', dbo.getutcdate);
    end if;

    -- If already exists, do not process again
    begin
        v_id_billgroup_exist := null;
        for i in (SELECT id_billgroup FROM t_invoice_range
        WHERE id_billgroup = p_id_billgroup and id_run is NULL)
        loop
            v_id_billgroup_exist := i.id_billgroup;
            exit;
        end loop;
        if v_id_billgroup_exist is not null then
            v_ErrMsg := 'InsertInvoice: Invoice number already exists in the t_invoice_range table, '
                      ||'process skipped, process completed successfully at '
                      || to_char(SYS_EXTRACT_UTC(SYSTIMESTAMP),'mon dd yyyy hh:mi:ss:ff PM');
            raise SkipReturn;
        end if;
    exception
    when SkipReturn then
        raise SkipReturn;
    when others then
        raise FatalError;
    END;

    begin
    v_id_interval_exist := NULL;
    for i in (SELECT id_interval FROM t_invoice inv
							INNER JOIN t_billgroup_member bgm
							ON bgm.id_acc = inv.id_acc
						INNER JOIN t_billgroup bg
							ON bg.id_usage_interval = inv.id_interval AND
								bg.id_billgroup = bgm.id_billgroup
						WHERE bgm.id_billgroup = p_id_billgroup and
												inv.sample_flag = 'N')
    loop
        v_id_interval_exist := i.id_interval;
        exit;
    end loop;
    IF v_id_interval_exist IS NOT NULL
    then
      v_ErrMsg := 'InsertInvoice: Invoice number already exists in the t_invoice table, '
                  ||'process skipped, process completed successfully at '
                  ||to_char(SYSTIMESTAMP,'mon dd yyyy hh:mi:ss:ff PM');
      raise SkipReturn;
    END IF;
    exception
    when SkipReturn then
        raise SkipReturn;
    when others then
        raise FatalError;
    end;

    /* call MTSP_INSERTINVOICE_BALANCES to populate tmp_acc_amounts, tmp_prev_balance, tmp_adjustments */
    MTSP_INSERTINVOICE_BALANCES (p_id_billgroup, 0, p_id_run, p_return_code);
    if p_return_code <> 0 then
        raise FatalError;
    end if;

    begin
      execute immediate 'begin '||p_invoicenumber_storedproc||'(:var1,:var2); end;' using v_invoice_date, in out v_cur1;
      loop
         fetch v_cur1 into v_tmp_invoicenumber;
         exit when v_cur1%NOTFOUND;
         INSERT INTO tmp_invoicenumber (id_acc,namespace,invoice_string,invoice_due_date,id_invoice_num)
         values (v_tmp_invoicenumber.id_acc,v_tmp_invoicenumber.namespace,v_tmp_invoicenumber.invoice_string,
                 v_tmp_invoicenumber.invoice_due_date,v_tmp_invoicenumber.id_invoice_num);
      end loop;
    exception
      when others then
      raise FatalError;
    end;

    IF v_debug_flag = 1 then
      INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
      VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'InsertInvoice: Begin Insert into t_invoice', dbo.getutcdate);
    end if;

    -- Save all the invoice data to the t_invoice table
    begin
    INSERT INTO t_invoice
      (id_invoice,
      namespace,
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
	  seq_t_invoice.nextval,
      tmp_acc_amounts.namespace,
      tmpin.invoice_string, -- from the stored proc as below
		  ui.id_interval, /*@id_interval,*/
      tmp_acc_amounts.id_acc,
      current_charges
        + nvl(tmp_adjustments.PrebillAdjAmt,0)
        + tax_ttl_amt
        + nvl(tmp_adjustments.PrebillTaxAdjAmt,0.0),  -- invoice_amount = current_charges + prebill adjustments + taxes + prebill tax adjustments,
      v_invoice_date invoice_date,
      tmpin.invoice_due_date, -- from the stored proc as @invoice_date+@invoice_due_date_offset   invoice_due_date,
      tmpin.id_invoice_num, -- from the stored proc as tmp_seq + @invoice_number - 1,
      invoice_currency,
      payment_ttl_amt, -- payment_ttl_amt
     nvl(tmp_adjustments.PostbillAdjAmt, 0.0) + nvl(tmp_adjustments.PostbillTaxAdjAmt, 0.0), -- postbill_adj_ttl_amt
      ar_adj_ttl_amt, -- ar_adj_ttl_amt
      tax_ttl_amt + nvl(tmp_adjustments.PrebillTaxAdjAmt,0.0), -- tax_ttl_amt
      current_charges + tax_ttl_amt + ar_adj_ttl_amt
          + nvl(tmp_adjustments.PostbillAdjAmt, 0.0)
        + nvl(tmp_adjustments.PostbillTaxAdjAmt,0.0)
        + payment_ttl_amt
          + nvl(tmp_prev_balance.previous_balance, 0.0)
        + nvl(tmp_adjustments.PrebillAdjAmt, 0.0)
        + nvl(tmp_adjustments.PrebillTaxAdjAmt,0.0), -- current_balance
      id_payer, -- id_payer
      CASE WHEN tmp_acc_amounts.id_payer_interval IS NULL THEN
      (SELECT id_usage_interval FROM t_billgroup WHERE id_billgroup = p_id_billgroup)
      ELSE tmp_acc_amounts.id_payer_interval END, -- id_payer_interval
      p_is_sample sample_flag,
      ui.dt_end -- balance_forward_date
    FROM tmp_acc_amounts
    INNER JOIN tmp_invoicenumber tmpin ON tmpin.id_acc = tmp_acc_amounts.id_acc
    LEFT OUTER JOIN tmp_prev_balance ON tmp_prev_balance.id_acc = tmp_acc_amounts.id_acc
    LEFT OUTER JOIN tmp_adjustments ON tmp_adjustments.id_acc = tmp_acc_amounts.id_acc
    INNER JOIN t_usage_interval ui ON ui.id_interval IN (SELECT id_usage_interval
			                                               FROM t_billgroup
			                                               WHERE id_billgroup = p_id_billgroup)/*= @id_interval*/
    INNER JOIN t_av_internal avi ON avi.id_acc = tmp_acc_amounts.id_acc;

    p_num_invoices := SQL%ROWCOUNT;
    exception
    when others then
      raise FatalError;
    end;

    -- Store the invoice range data to the t_invoice_range table
    begin
    SELECT MAX(tmp_seq) into v_cnt
    FROM tmp_acc_amounts;
    exception
    when others then
      raise FatalError;
    end;

    IF v_cnt IS NOT NULL then
    BEGIN
      --insert info about the current run into the t_invoice_range table
      INSERT INTO t_invoice_range (id_interval,id_billgroup, namespace, id_invoice_num_first, id_invoice_num_last)
      SELECT i.id_interval, bm.id_billgroup, i.namespace, nvl(min(id_invoice_num),0), nvl(max(id_invoice_num),0)
      FROM t_invoice i
        INNER JOIN t_billgroup_member bm ON bm.id_acc = i.id_acc
        INNER JOIN t_billgroup b ON b.id_billgroup = bm.id_billgroup 
                                AND i.id_interval = b.id_usage_interval
      WHERE bm.id_billgroup = p_id_billgroup
      GROUP by i.id_interval, bm.id_billgroup, i.namespace;

      --update the id_invoice_num_last in the t_invoice_namespace table

      UPDATE t_invoice_namespace
      SET t_invoice_namespace.id_invoice_num_last =
        (SELECT CASE WHEN nvl(max(t_invoice.id_invoice_num), 0) > t_invoice_namespace.id_invoice_num_last THEN nvl(max(t_invoice.id_invoice_num), 0) ELSE t_invoice_namespace.id_invoice_num_last END
         FROM t_invoice
     	   INNER JOIN t_billgroup_member on t_billgroup_member.id_acc = t_invoice.id_acc
     	   INNER JOIN t_billgroup on t_billgroup.id_billgroup = t_billgroup_member.id_billgroup
         WHERE t_invoice_namespace.namespace = t_invoice.namespace 
  		 AND t_invoice.id_interval = t_billgroup.id_usage_interval
         AND t_billgroup.id_billgroup = p_id_billgroup);
		
	exception
	when others then
      raise FatalError;
    END;
    ELSE
      v_cnt := 0;
    end if;

    IF v_debug_flag = 1 then
      INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
       VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'InsertInvoice: Completed successfully', dbo.getutcdate);
    end if;
    p_return_code := 0;
    RETURN;

exception
when SkipReturn then
      IF v_ErrMsg IS NULL then
        v_ErrMsg := 'InsertInvoice: Process skipped';
      end if;
      IF v_debug_flag = 1  then
        INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
                    VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', v_ErrMsg, dbo.getutcdate);
      end if;
      p_return_code := 0;
      RETURN;

-- others will catch anything else including fatalexceptions 
when Others then
      IF v_ErrMsg IS NULL then
        v_ErrMsg := 'InsertInvoice: Adapter stored procedure failed';
      end if;
      IF v_debug_flag = 1 then
        INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
          VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', v_ErrMsg, dbo.getutcdate);
      END IF;
      p_return_code := -1;
      RETURN;

END;
