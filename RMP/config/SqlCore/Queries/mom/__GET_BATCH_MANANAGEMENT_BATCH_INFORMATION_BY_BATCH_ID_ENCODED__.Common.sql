  
        select id_batch BatchTableId, tx_batch_encoded BatchId, tx_name Name, 
				tx_namespace Namespace, 
				case tx_status when 'A' Then 'Active' 
				when 'B' Then 'Backed Out' when 'D' Then 'Dismissed' 
				when 'X' Then 'Resubmitted' when 'F' Then 'Failed' 
				when 'C' Then 'Completed' else 'Unknown Status' end Status,
				tx_source "Source", tx_sequence "Sequence", 
				dt_crt Creation, dt_first First, dt_last Recent, 
				n_completed Completed, n_failed Failed, n_expected Expected, n_dismissed Dismissed 
				/* CAUTION: Batch Encoded is case sensitive, so by converting it to upper
					we may mask a bug - although the goal for now is to make behavior consistent with SQL server
				*/
				FROM t_batch WHERE %%%UPPER%%%(tx_batch_encoded)=%%%UPPER%%%('%%ID_BATCH_ENCODED%%')
 			