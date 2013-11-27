
      create global temporary table tmp_fail_txn_bulk_stat_upd
		(
		    sequence number(10),
		    status number(10),
		    tx_failurecompoundid raw(16)
		)
			