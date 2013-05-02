
        insert into t_ps_preauth_details
          (
			  id_preauth_tx_id_detail,
	          id_preauth_tx_id,
	          nm_invoice_num,
	          dt_invoice_date,
	          nm_po_number,
			  n_amount
		  ) 
			  values
          (
		   ?, ?, ?, ?, ?, ?
          )    
        