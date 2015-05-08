
update t_failed_transaction
/* __FAILED_STATUS_BULK_UPDATE_FROM_BULK_TABLE__ */
set state = '%%NEWSTATUS%%',
    resubmit_Guid = NULL,
    dt_Start_Resubmit = NULL
where exists (
        select tmp.tx_failurecompoundid
        from   %%%TEMP_TABLE_PREFIX%%%tmp_fail_txn_bulk_stat_upd tmp
        where      tmp.tx_failurecompoundid =
                                t_failed_transaction.tx_failurecompoundid
                and tmp.status = 0)
  and state <> 'D'
  and state <> 'R'
			