
          CREATE TABLE t_invoice
          (
          id_invoice number(10) NOT NULL,
          namespace nvarchar2(40) NOT NULL,
          invoice_string nvarchar2(50) NOT NULL,
          id_interval number(10) NOT NULL,
          id_acc number(10) NOT NULL,
          invoice_amount number(22,10) NOT NULL,
          invoice_date date NOT NULL,
          invoice_due_date date NOT NULL,
          id_invoice_num number(10) NOT NULL,
          invoice_currency nvarchar2(10) NOT NULL,
          payment_ttl_amt number(22,10) NOT NULL,
          postbill_adj_ttl_amt number(22,10) NOT NULL,
          ar_adj_ttl_amt number(22,10) NOT NULL,
          tax_ttl_amt number(22,10) NOT NULL,
          current_balance number(22,10) NOT NULL,
          id_payer number(10) NOT NULL,
          id_payer_interval number(10) NOT NULL,
          sample_flag varchar2(1)NOT NULL,
          balance_forward_date DATE NULL,
          div_currency nvarchar2(3) NULL,
          div_amount number(22,10) NULL,
          CONSTRAINT PK_t_invoice PRIMARY KEY (id_invoice)
          )
        