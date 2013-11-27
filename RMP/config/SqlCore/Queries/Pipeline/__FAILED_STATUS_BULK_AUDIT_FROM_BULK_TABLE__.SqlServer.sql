
          INSERT INTO t_audit
          /* __FAILED_STATUS_BULK_AUDIT_FROM_BULK_TABLE__ */
          (id_audit, id_event,id_userid, id_entitytype, id_entity, dt_crt)
          SELECT %%AUDITSTARTID%%+tmp.sequence, 1701, %%USERID%%, 5, ft.id_failed_transaction, %%%SYSTEMDATE%%%
          FROM #tmp_fail_txn_bulk_stat_upd tmp
          join t_failed_transaction ft on tmp.tx_FailureCompoundID = ft.tx_FailureCompoundID and tmp.status=0 
          AND ft.State <> 'D' and ft.State <> 'R'
          INSERT INTO t_audit_details(id_audit, tx_details)
          SELECT %%AUDITSTARTID%%+tmp.sequence, '%%AUDITDETAILS%%'
          FROM #tmp_fail_txn_bulk_stat_upd tmp where tmp.status=0
        