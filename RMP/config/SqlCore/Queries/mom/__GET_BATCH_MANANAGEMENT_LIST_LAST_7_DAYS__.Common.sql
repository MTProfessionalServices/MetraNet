      
        select id_batch as BatchTableId, tx_batch_encoded as BatchId, tx_name as Name, tx_namespace as Namespace,
				case tx_status when 'A' Then 'Active' when 'B' Then 'Backed Out' when 'D' Then 'Dismissed' 
				when 'X' Then 'Resubmitted' when 'F' Then 'Failed' when 'C' Then 'Completed' 
				else 'Unknown Status' end as Status,
				tx_source as Source, tx_sequence as Sequence, dt_crt as Creation, 
				dt_first as First, dt_last as Recent, n_completed as Completed, 
				n_failed as Failed, n_expected as Expected, n_dismissed Dismissed from t_batch
        where not exists (select * from t_recevent_run_batch 
				where t_recevent_run_batch.tx_batch_encoded = t_batch.tx_batch_encoded) 
				AND 
				CAST(%%%SYSTEMDATE%%% - dt_crt AS INT) BETWEEN 0 AND 7
				/* DATEDIFF(dd, dt_crt, %%%SYSTEMDATE%%%)<7 - former SQL server version */
				/* (%%%SYSTEMDATE%%% - dt_crt) between 0 and 7 - former Oracle version */
 			