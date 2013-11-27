           
          select id_batch BatchTableId, tx_batch_encoded BatchId, tx_name Name, 
				tx_namespace Namespace, 
				case tx_status when 'A' Then 'Active' 
				when 'B' Then 'Backed Out' when 'D' Then 'Dismissed' 
				when 'X' Then 'Resubmitted' when 'F' Then 'Failed' 
				when 'C' Then 'Completed' else 'Unknown Status' end Status,
				tx_source "Source", tx_sequence "Sequence", 
				dt_crt Creation, dt_first First, dt_last Recent, 
				n_completed Completed, n_failed Failed, n_expected Expected, n_dismissed Dismissed 
				from t_batch
				where exists 
				(select * from t_recevent_run_batch rrb 
				where rrb.tx_batch_encoded = t_batch.tx_batch_encoded and rrb.id_run=%%ID_RUN%%)
 			