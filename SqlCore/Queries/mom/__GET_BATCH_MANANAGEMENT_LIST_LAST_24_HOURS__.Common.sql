      
        select id_batch BatchTableId, tx_batch_encoded BatchId, tx_name Name, 
				tx_namespace Namespace,
				case tx_status when 'A' Then 'Active' when 'B' Then 'Backed Out' 
				when 'D' Then 'Dismissed' when 'X' Then 'Resubmitted' when 'F' Then 'Failed' 
				when 'C' Then 'Completed' else 'Unknown Status' end Status,
				tx_source Source, tx_sequence Sequence, dt_crt Creation, 
				dt_first First, dt_last Recent, n_completed Completed, 
				n_failed Failed, n_expected Expected, n_dismissed Dismissed from t_batch
        where not exists 
				(select * from t_recevent_run_batch 
				where t_recevent_run_batch.tx_batch_encoded = t_batch.tx_batch_encoded) 
				AND 
				CAST(%%%SYSTEMDATE%%% - dt_crt AS INT) BETWEEN 0 AND 1
				/* DATEDIFF(hh, dt_crt, %%%SYSTEMDATE%%%)<24  - former SQL server version */
				/* ( %%%SYSTEMDATE%%% - dt_crt) BETWEEN 0 AND 1  - former Oracle version */
 			