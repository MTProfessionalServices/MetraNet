
         create global temporary table tmp_invoicenumber
             (
                id_acc            number(10) NOT NULL,
                namespace         nvarchar2(40) NOT NULL,
                invoice_string    nvarchar2(50) NOT NULL,
                invoice_due_date  date NOT NULL,
                id_invoice_num    number(10) NOT NULL
             ) on commit preserve rows
        