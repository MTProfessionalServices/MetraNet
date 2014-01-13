
        SELECT 
          amPayee.nm_login as "FromExtAccountID",
          amPayer.nm_login as "ToExtAccountID",
          '%%BATCH_ID%%' as "BatchID",
          '%%MOVE_DATE%%' as "MoveDate"
        FROM t_payment_redir_history curPR
          JOIN t_account_mapper amPayer ON amPayer.id_acc = curPR.id_payer and amPayer.nm_space = '%%NAME_SPACE%%'
          JOIN t_account_mapper amPayee ON amPayee.id_acc = curPR.id_payee and amPayee.nm_space = '%%NAME_SPACE%%'
        WHERE %%CURRENT_RUN_TIME%% BETWEEN tt_start AND tt_end
          AND %%CURRENT_RUN_TIME%% BETWEEN vt_start AND vt_end
          AND id_payer != id_payee  -- not paying for self
          AND id_payer NOT IN       -- payer has changed
            (-- payer at START_TIME (can be NULL)
            SELECT id_payer FROM t_payment_redir_history lastPR
            WHERE curPR.id_payee = lastPR.id_payee
            AND %%LAST_RUN_TIME%% BETWEEN lastPR.tt_start AND lastPR.tt_end
            AND %%LAST_RUN_TIME%% BETWEEN lastPR.vt_start AND lastPR.vt_end
            )
        ORDER BY curPR.vt_start     -- process A->B, B->C changes in order of occurrence
        