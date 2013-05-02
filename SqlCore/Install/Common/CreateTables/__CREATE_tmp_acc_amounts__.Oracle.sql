
         create global temporary table tmp_acc_amounts
             (
                tmp_seq number(10) ,
                namespace nvarchar2(40),
                id_interval number(10),
                id_acc number(10),
                invoice_currency nvarchar2(10),
                payment_ttl_amt number(22,10),
                postbill_adj_ttl_amt number(22,10),
                ar_adj_ttl_amt number(22,10),
                previous_balance number(22,10),
                tax_ttl_amt number(22,10),
                current_charges number(22,10),
                id_payer number(10),
                id_payer_interval number(10)
             ) on commit preserve rows
        