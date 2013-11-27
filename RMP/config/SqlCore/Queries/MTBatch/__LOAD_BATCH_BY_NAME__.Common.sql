
			   SELECT * FROM t_batch WHERE tx_name = '%%BATCH_NAME%%' 
				 AND tx_namespace = '%%BATCH_NAMESPACE%%' AND tx_sequence
				 = '%%BATCH_SEQUENCENUMBER%%'
			