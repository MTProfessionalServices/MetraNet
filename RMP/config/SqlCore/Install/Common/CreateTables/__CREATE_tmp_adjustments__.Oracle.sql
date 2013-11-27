
         create global temporary table tmp_adjustments
             (
                id_acc number(10),
                PrebillAdjAmt number(22,10),
                PrebillTaxAdjAmt number(22,10),
                PostbillAdjAmt number(22,10),
                PostbillTaxAdjAmt number(22,10)
             )  on commit preserve rows
        