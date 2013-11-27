
			  INSERT INTO t_pending_payment_trans_dtl
				(
          id_detail,
					id_pending_payment,
					nm_invoice_num,
					dt_invoice,
					nm_po_number,
					n_amount
				)
				VALUES
				(
					seq_t_pending_payment_dtl.nextval, ?, ?, ?, ?, ?
				)
			  