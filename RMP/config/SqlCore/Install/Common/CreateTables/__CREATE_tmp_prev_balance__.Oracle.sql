
         create global temporary table tmp_prev_balance
             (
                id_acc number(10),
                previous_balance number(22,10)
             ) on commit preserve rows
        