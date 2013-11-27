
update %%%TEMP_TABLE_PREFIX%%%tmp_fail_txn_bulk_stat_upd
/* __FAILED_STATUS_BULK_VALIDATE_REQUEST__ */
set status = -517996499   /* PIPE_ERR_FAILED_TRANSACTION_INVALID_STATUS_CHANGE*/
where  not exists (
	select ft.tx_failurecompoundid
	from   t_failed_transaction ft
	where      %%%TEMP_TABLE_PREFIX%%%tmp_fail_txn_bulk_stat_upd.tx_failurecompoundid = ft.tx_failurecompoundid
	       and state <> 'D'
	       and state <> 'R')
        