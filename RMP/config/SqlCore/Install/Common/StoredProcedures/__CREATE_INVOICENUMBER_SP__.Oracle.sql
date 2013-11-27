
    CREATE OR REPLACE PROCEDURE MTSP_INSERTINVOICE_DEFLTINVNUM
    (p_invoice_date DATE,
    P_cursor OUT sys_refcursor)
    IS
    begin
      OPEN p_cursor for
      SELECT
      tmp.id_acc id_acc,
      tmp.namespace namespace,
      tins.invoice_prefix
       || NVL(RPAD('0', tins.invoice_num_digits - LENGTH(RTRIM(CAST((tmp.tmp_seq + tins.id_invoice_num_last + 1 - 1) as nvarchar2(11)))),'0'),'')
       || RTRIM(CAST((tmp.tmp_seq + tins.id_invoice_num_last + 1 - 1) as nvarchar2(11)))
       || tins.invoice_suffix invoice_num,
      p_invoice_date+tins.invoice_due_date_offset invoice_dt,
      tmp.tmp_seq + tins.id_invoice_num_last inv_no
      FROM tmp_acc_amounts tmp
      INNER JOIN t_invoice_namespace tins ON tins.namespace = tmp.namespace;
    end;
        