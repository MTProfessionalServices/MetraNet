
        /*  gets last calculated balance for an account */
        /*  or latest calculated balance based on a cut-off date */
        CREATE or replace PROCEDURE GetLastBalance(
        p_id_acc int,                    /* account */
        p_before_date date,              /* last balance before this date, can be NULL */
        p_balance OUT number,            /* the balance */
        p_balance_date OUT date ,        /* the date the balance was computed */
        p_currency OUT nvarchar2         /* currency for account */
        )
        AS
        BEGIN
          for i in (SELECT inv.current_balance current_balance, ui.dt_end dt_end, inv.invoice_currency invoice_currency
          FROM t_invoice inv  JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
          WHERE id_acc = p_id_acc
          AND (p_before_date IS NULL OR ui.dt_end < p_before_date)
          ORDER BY ui.dt_end DESC)
          loop
              p_balance      := i.current_balance;
              p_balance_date := i.dt_end;
              p_currency     := i.invoice_currency;
              exit;
          end loop;
          IF p_balance IS NULL then
                p_balance  := 0;
                for i in( select c_currency from t_av_internal where id_acc = p_id_acc) LOOP
                    p_currency := i.c_currency;
                END LOOP;
                p_balance_date := to_date('1900-01-01','yyyy-mm-dd');
            END if;
        END;
     