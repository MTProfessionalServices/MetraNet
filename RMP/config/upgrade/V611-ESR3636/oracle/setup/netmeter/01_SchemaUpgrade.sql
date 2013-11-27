DECLARE
  cnt number;
  
BEGIN
  BEGIN
      select count(*) INTO cnt
      from user_objects 
      where object_type = 'TABLE' and object_name = 'T_PAYMENT_HISTORY_DETAILS';
      IF cnt > 0 THEN
              EXECUTE IMMEDIATE  'DROP TABLE T_PAYMENT_HISTORY_DETAILS';
      END IF;
  END;


  BEGIN 
  EXECUTE IMMEDIATE 'CREATE TABLE t_payment_history_details (
  id_payment_transaction VARCHAR2(40) NOT NULL,
  id_payment_history_details integer NOT NULL,
  nm_invoice_num nvarchar2(50) NULL,
  dt_invoice_date timestamp NOT NULL,
  nm_po_number nvarchar2(30) NULL,
  n_amount NUMERIC(16,2) NULL,
  PRIMARY KEY (id_payment_transaction, id_payment_history_details))';
  END;
  
  




  BEGIN
  
    select  count(*) INTO cnt
    from user_tab_columns  
    where table_name = 'T_PAYMENT_HISTORY' and COLUMN_NAME = 'NM_INVOICE_NUM';
  
    IF cnt > 0 THEN
    
      EXECUTE IMMEDIATE 'INSERT INTO T_PAYMENT_HISTORY_DETAILS
                        SELECT id_payment_transaction,
                          1,
                          nm_invoice_num, 
                          dt_invoice_date,
                          nm_po_number,
                          n_amount
                          from t_payment_history';
                          
      EXECUTE IMMEDIATE 'alter table t_payment_history drop (nm_invoice_num ,dt_invoice_date , nm_po_number)';
    END IF;
  END;
  
  EXECUTE IMMEDIATE 'alter table t_pending_ach_trans_details add (dt_invoice timestamp NULL , nm_po_number nvarchar2(30) NULL)';
  
END;  

  