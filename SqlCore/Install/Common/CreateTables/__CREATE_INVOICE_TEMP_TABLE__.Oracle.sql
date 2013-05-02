
     CREATE GLOBAL TEMPORARY TABLE tmp_invoice_1
        (tmp_seq number(10),
        namespace varchar2 (200),
        id_interval number(10),
        id_acc number(10),
        invoice_amount number(22,10),
        /* invoice_tax number(22,10), */
        invoice_date DATE,
        invoice_due_date DATE,
        invoice_currency VARCHAR(10))
     ON COMMIT PRESERVE ROWS
