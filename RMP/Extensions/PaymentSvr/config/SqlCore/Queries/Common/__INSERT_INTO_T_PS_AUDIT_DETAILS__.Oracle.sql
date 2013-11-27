
        insert into t_ps_audit_details
          (
		  id_audit_detail,
          id_audit,
          nm_invoice_num,
          dt_invoice_date,
          nm_po_number,
          n_amount
          ) 
			  values
          ( ?, ?, ?, ?, ?, ? )         
        