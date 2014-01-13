
        CREATE TABLE t_invoice
        (
        id_invoice int identity(1,1) NOT NULL,
        namespace nvarchar(40) NOT NULL,
        invoice_string nvarchar(50) NOT NULL,
        id_interval int NOT NULL, id_acc int NOT NULL,
        invoice_amount numeric (22,10) NOT NULL,
        invoice_date DATETIME NOT  NULL,
        invoice_due_date DATETIME NOT NULL,
        id_invoice_num int NOT NULL,
        invoice_currency nvarchar(10) NOT NULL,
        payment_ttl_amt numeric (22,10) NOT NULL,
        postbill_adj_ttl_amt numeric (22,10) NOT NULL,
        ar_adj_ttl_amt numeric (22,10) NOT NULL,
        tax_ttl_amt numeric (22,10) NOT NULL,
        current_balance numeric (22,10) NOT NULL,
        id_payer int NOT NULL,
        id_payer_interval int NOT NULL,
        sample_flag varchar(1)NOT NULL,
        balance_forward_date DATETIME NULL,
        div_currency nvarchar(3) NULL,
        div_amount numeric(22,10) NULL,
        CONSTRAINT PK_t_invoice PRIMARY KEY CLUSTERED (id_invoice)
        )
      