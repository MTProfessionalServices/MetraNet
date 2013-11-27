
        select 
			bh.dt_history_crt "Date History",
			case
				when bh.tx_status = 'A' Then 'Active'
				when bh.tx_status = 'B' Then 'Backout'
				when bh.tx_status = 'C' Then 'Completed'
				when bh.tx_status = 'F' Then 'Failed'
				when bh.tx_status = 'D' Then 'Dismissed'
			end "Status",
			bh.n_completed "Completed",
			bh.n_failed "Failed",
			bh.n_dismissed "Dismissed",
			bh.n_expected "Expected",
			bh.n_metered "Metered",
			bh.dt_first "Date First",
			bh.dt_last "Date Last"
		from t_batch_history bh
		inner join t_batch b on bh.tx_batch_encoded = b.tx_batch_encoded
        where bh.tx_batch=%%ID_BATCH%%
		order by dt_history_crt desc
			 