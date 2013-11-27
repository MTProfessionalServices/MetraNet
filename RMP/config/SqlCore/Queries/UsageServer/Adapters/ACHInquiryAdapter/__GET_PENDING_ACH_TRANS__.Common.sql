
         select 
	        ppa.id_payment_transaction,
	        ppa.n_days,
	        ppa.id_acc,
	        ppa.id_payment_instrument,
            ppad.nm_invoice_num,
	        ppa.nm_description,
	        ppa.n_amount,
			tp.nm_truncd_acct_num, 
			ppa.nm_ar_request_id,
			ppad.dt_invoice,
			ppad.nm_po_number,
			ppad.n_amount n_invoice_amount			
        from t_pending_ach_trans ppa
		LEFT OUTER JOIN t_pending_ach_trans_details ppad on ppa.id_payment_transaction = ppad.id_payment_transaction
		    inner join t_payment_instrument tp on ppa.id_payment_instrument = tp.id_payment_instrument
        where n_days < %%MAX_DAYS%%
       