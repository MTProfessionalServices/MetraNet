
        SELECT
          am.nm_login as ExtAccountID,
          Status,
          tt_start
        FROM t_account_state_history curState
        JOIN t_account_mapper am ON am.id_acc = curState.id_acc and am.nm_space = '%%NAME_SPACE%%'
        JOIN t_av_internal ai ON ai.id_acc = curState.id_acc and ai.c_billable = '1'
        JOIN t_account acc ON acc.id_acc = curState.id_acc 
        JOIN t_account_type atype ON acc.id_type = atype.id_type and atype.name NOT IN ('SYSTEMACCOUNT')
        WHERE %%CURRENT_RUN_TIME%% BETWEEN tt_start AND tt_end
        AND   %%CURRENT_RUN_TIME%% BETWEEN vt_start AND vt_end
        AND tt_start NOT IN 
          (-- -- history record used at last run (can be NULL)
          SELECT tt_start FROM t_account_state_history lastState
          WHERE curState.id_acc = lastState.id_acc
          AND %%LAST_RUN_TIME%% BETWEEN lastState.tt_start AND lastState.tt_end
          AND %%LAST_RUN_TIME%% BETWEEN lastState.vt_start AND lastState.vt_end
          )
        