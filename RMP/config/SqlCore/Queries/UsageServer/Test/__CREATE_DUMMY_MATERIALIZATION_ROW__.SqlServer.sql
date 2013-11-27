
        /* ===========================================================
        Create a dummy materialization row with the given status.
        ============================================================== */
        INSERT INTO t_billgroup_materialization 
        (id_user_acc, dt_start, id_usage_interval, tx_status, tx_type)
        VALUES  
        (%%USERID%%, %%DT_START%%, %%ID_INTERVAL%%, '%%STATUS%%', '%%TYPE%%')
         