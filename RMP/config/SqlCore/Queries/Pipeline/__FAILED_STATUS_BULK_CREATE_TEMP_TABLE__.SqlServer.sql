
             if object_id( 'tempdb..#tmp_fail_txn_bulk_stat_upd' ) is not null
             /* __FAILED_STATUS_BULK_CREATE_TEMP_TABLE__ */
                DROP TABLE #tmp_fail_txn_bulk_stat_upd

      			 create table #tmp_fail_txn_bulk_stat_upd
      			 (
             			   sequence int identity(0,1),
                     status int,
                     tx_FailureCompoundID varbinary (16)
      			 )
        