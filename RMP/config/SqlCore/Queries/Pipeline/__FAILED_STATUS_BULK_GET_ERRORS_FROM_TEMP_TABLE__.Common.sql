
select tx_FailureCompoundID, status 
/* __FAILED_STATUS_BULK_GET_ERRORS_FROM_TEMP_TABLE__ */
from %%%TEMP_TABLE_PREFIX%%%tmp_fail_txn_bulk_stat_upd
where status <> 0
        