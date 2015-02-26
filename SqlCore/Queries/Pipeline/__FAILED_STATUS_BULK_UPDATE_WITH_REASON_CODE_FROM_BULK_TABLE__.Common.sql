
update t_failed_transaction
/* __FAILED_STATUS_BULK_UPDATE_WITH_REASON_CODE_FROM_BULK_TABLE__ */
set state = '%%NEWSTATUS%%',
    tx_statereasoncode = '%%NEWREASONCODE%%',
    dt_Start_Resubmit = NULL,
    resubmit_Guid = NULL
where  exists (
       select tmp.tx_failurecompoundid
       from   %%%TEMP_TABLE_PREFIX%%%tmp_fail_txn_bulk_stat_upd tmp
       where      tmp.tx_failurecompoundid =
                              t_failed_transaction.tx_failurecompoundid
              and tmp.status = 0)
and state <> 'D'
and state <> 'R'
			